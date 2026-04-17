# frozen_string_literal: true

# shadcn divergence: child parts (`list`, `trigger`, `content`) are
# orphan-protected — they only render when called through a `:tabs`-kind
# `Shadcnrb::Scope` (yielded by `sui.tabs do |t| ... end`).

module Shadcnrb
  class Tabs < Component
    # `variant:` — `:default` (rounded muted pill, shadcn default) or `:line`
    # (underline-style tab strip).
    # `orientation:` — `:horizontal` or `:vertical`.
    def tabs(default_value: nil, variant: :default, orientation: :horizontal, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(
        slot: "tabs",
        controller: "shadcnrb--tabs--component",
        "shadcnrb--tabs--component-active-value": default_value.to_s,
        "shadcnrb--tabs--component-variant-value": variant.to_s,
        orientation: orientation.to_s
      )
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
      scope = Scope.new(@builder, kind: :tabs, component: self)
      content_tag(:div, **opts) do
        block ? capture(scope, &block) : "".html_safe
      end
    end

    def list(variant: :default, orientation: :horizontal, scope: nil, **opts, &block)
      style = self.class.style
      opts[:data] = (opts[:data] || {}).merge(slot: "tabs-list", orientation: orientation.to_s)
      opts[:class] = Shadcnrb::TailwindMerge.call(
        style.list_base,
        Shadcnrb::TailwindMerge.fetch_variant(style.list_variants, variant, kind: :variant, component: "tabs"),
        opts[:class]
      )
      content_tag(:div, role: "tablist", **opts) { scope.capture_block(&block) }
    end

    def trigger(name = nil, value:, variant: :default, scope: nil, **opts, &block)
      style = self.class.style
      opts[:data] = (opts[:data] || {}).merge(
        slot: "tabs-trigger",
        action: "click->shadcnrb--tabs--component#select",
        "tab-value": value.to_s
      )
      opts[:class] = Shadcnrb::TailwindMerge.call(
        style.trigger_base,
        Shadcnrb::TailwindMerge.fetch_variant(style.trigger_variants, variant, kind: :variant, component: "tabs"),
        opts[:class]
      )
      opts[:type] ||= "button"
      button_tag(role: "tab", **opts) do
        block ? capture(&block) : name.to_s
      end
    end

    def content(value:, scope: nil, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(slot: "tabs-content", "tab-value": value.to_s)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.content, opts[:class])
      content_tag(:div, role: "tabpanel", **opts) { scope.capture_block(&block) }
    end

    private :list, :trigger, :content
  end
end
