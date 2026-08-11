# frozen_string_literal: true

# shadcn divergence: child part (`tab`) is orphan-protected — it only renders
# when called through a `:tabs`-kind `Shadcnrb::Scope` (yielded by
# `sui.tabs do |t| ... end`).

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
    # and every panel.
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
        strip = tab_list(variant:, orientation:, **list) do
          safe_join(tabs.each_with_index.map { |t, i|
            tab_trigger(t[:name], value: "tab-#{i + 1}", variant:, **t[:opts])
          })
        end
        panels = tabs.each_with_index.map { |t, i|
          tab_panel(t[:body], value: "tab-#{i + 1}", **content)
        }
        safe_join([ strip, *panels ])
      end
    end

    private

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

    def tab_panel(body, value:, **opts)
      opts[:data] = (opts[:data] || {}).merge(slot: "tabs-content", "tab-value": value)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.content, opts[:class])
      content_tag(:div, body, role: "tabpanel", **opts)
    end
  end
end
