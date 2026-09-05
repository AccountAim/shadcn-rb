# frozen_string_literal: true

# shadcn divergence: child part (`tab`) is orphan-protected — it only renders
# when called through a `:tabs`-kind `Shadcnrb::Scope` (yielded by
# `sui.tabs do |t| ... end`). Inactive panels render with `hidden` and
# `data-state` server-side, not only once the controller connects, so lazy
# frames inside them don't load before the first paint.

module Shadcnrb
  class Tabs < Component
    # Each `t.tab` is one trigger + panel pair — the tab strip and the
    # panels are assembled from them, and the shared value is minted
    # internally (pairing is structural, like navigation_menu). The first
    # tab starts active unless one passes `active: true`.
    #
    #   sui.tabs do |t|
    #     t.tab "Account" do
    #       ...panel...
    #     end
    #     t.tab "Password", active: true do
    #       ...panel...
    #     end
    #   end
    #
    # `variant:` — `:default` (rounded muted pill, shadcn default) or `:line`
    # (underline-style tab strip). `orientation:` — `:horizontal` or
    # `:vertical`. `list:` / `content:` are option hashes for the tab strip
    # and every panel; `list: false` renders the panels alone so a
    # `tabs_strip` can drive them from elsewhere on the page.
    def tabs(variant: :default, orientation: :horizontal, list: {}, content: {}, **opts, &block)
      scope = Scope.new(@builder, kind: :tabs, component: self)
      # Saved and restored so tabs rendered inside another tab's panel don't
      # leak into the outer strip.
      outer, @tabs = @tabs, []
      capture(scope, &block) if block
      tabs, @tabs = @tabs, outer

      active = tabs.index { |t| t[:active] } || 0
      opts[:data] = (opts[:data] || {}).merge(
        slot: "tabs",
        controller: "shadcnrb--tabs--component",
        "shadcnrb--tabs--component-active-value": "tab-#{active + 1}",
        "shadcnrb--tabs--component-variant-value": variant.to_s,
        orientation: orientation.to_s
      )
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])

      content_tag(:div, **opts) do
        strip = strip_for(tabs, variant:, orientation:, **list) if list
        panels = tabs.each_with_index.map { |t, i|
          tab_panel(t[:body], value: "tab-#{i + 1}", active: i == active, **content)
        }
        safe_join([ strip, *panels ].compact)
      end
    end

    # A detached tab strip for the `sui.tabs id: tabs, list: false` root;
    # its triggers carry `data-tabs` and can sit anywhere in the document.
    # `names` repeats the tab labels in order, `trigger:` applies to every
    # trigger, and remaining options go to the list element. `variant:`
    # should match the root's.
    #
    #   sui.tabs_strip tabs: "revenue-tabs", names: %w[Chart Data]
    def tabs_strip(tabs:, names:, variant: :default, trigger: {}, **opts)
      data = (trigger[:data] || {}).merge(tabs:)
      entries = names.map { |name| { name:, opts: trigger.merge(data:) } }
      strip_for(entries, variant:, orientation: :horizontal, **opts)
    end

    private

    def strip_for(entries, variant:, orientation:, **opts)
      tab_list(variant:, orientation:, **opts) do
        safe_join(entries.each_with_index.map { |entry, i|
          tab_trigger(entry[:name], value: "tab-#{i + 1}", variant:, **entry[:opts])
        })
      end
    end

    # Collects (label, panel) pairs during the block pass; `tabs` renders
    # the strip and panels from them afterwards. Returns nothing.
    def tab(name = nil, active: false, scope: nil, **opts, &block)
      @tabs << { name:, active:, opts:, body: scope.capture_block(&block) }
      "".html_safe
    end

    def tab_list(variant:, orientation:, **opts, &block)
      style = self.class.style
      opts[:data] = (opts[:data] || {}).merge(slot: "tabs-list", orientation: orientation.to_s)
      opts[:class] = Shadcnrb::TailwindMerge.call(
        style.list_base,
        Shadcnrb::TailwindMerge.fetch_variant(style.list_variants, variant, kind: :variant, component: "tabs"),
        opts[:class]
      )
      content_tag(:div, role: "tablist", **opts, &block)
    end

    def tab_trigger(name, value:, variant:, **opts)
      style = self.class.style
      opts[:data] = (opts[:data] || {}).merge(
        slot: "tabs-trigger",
        action: "click->shadcnrb--tabs--component#select",
        "tab-value": value
      )
      opts[:class] = Shadcnrb::TailwindMerge.call(
        style.trigger_base,
        Shadcnrb::TailwindMerge.fetch_variant(style.trigger_variants, variant, kind: :variant, component: "tabs"),
        opts[:class]
      )
      opts[:type] ||= "button"
      button_tag(name.to_s, role: "tab", **opts)
    end

    def tab_panel(body, value:, active:, **opts)
      opts[:data] = (opts[:data] || {}).merge(
        slot: "tabs-content", "tab-value": value, state: active ? "active" : "inactive"
      )
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.content, opts[:class])
      content_tag(:div, body, role: "tabpanel", hidden: !active, **opts)
    end
  end
end
