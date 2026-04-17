# frozen_string_literal: true

# shadcn divergence: Stimulus `shadcnrb--collapsible--component` controller replaces
# Radix `CollapsiblePrimitive.Root`. Content uses `hidden
# data-[state=open]:block` (same pattern as dropdown_menu) to avoid leaving
# the hidden panel in layout. upstream: collapsible.tsx.
#
# shadcn divergence: child parts (`trigger`, `content`, `chevron`) are
# orphan-protected — they only render when called through a `:collapsible`-kind
# `Shadcnrb::Scope` (yielded by `sui.collapsible do |c| ... end` or via
# `sui.collapsible_proxy`).

module Shadcnrb
  class Collapsible < Component
    # `open:` seeds the initial state; toggle with any descendant carrying
    # `data-action="click->shadcnrb--collapsible--component#toggle"` (use
    # `c.trigger` for a default button, or stamp the attribute onto
    # an existing button like `s.menu_button`).
    def collapsible(open: false, **opts, &block)
      state = open ? "open" : "closed"
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(
        slot: "collapsible",
        state:,
        controller: [ "shadcnrb--collapsible--component", opts.dig(:data, :controller) ].compact.join(" "),
        "shadcnrb--collapsible--component-open-value": open.to_s
      )
      content_tag(:div, **opts) do
        block ? capture(proxy, &block) : "".html_safe
      end
    end

    # Bare scope for rendering parts outside a `sui.collapsible` block —
    # e.g. a chevron stamped onto a trigger in a sibling scope.
    def proxy
      Scope.new(@builder, kind: :collapsible, component: self)
    end

    def trigger(name = nil, scope: nil, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(
        slot: "collapsible-trigger",
        action: merge_action(opts[:data], "click->shadcnrb--collapsible--component#toggle")
      )
      opts[:type] ||= "button"
      button_tag(**opts) do
        block ? capture(&block) : name.to_s
      end
    end

    def content(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.content, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(
        slot: "collapsible-content",
        "shadcnrb--collapsible--component-target": "content",
        state: "closed"
      )
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    # Standard rotating chevron for collapsible triggers. Reads the surrounding
    # `group/collapsible`'s `data-state` and flips on open.
    def chevron(name = :"chevron-down", scope: nil, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.chevron, opts[:class])
      icon(name, **opts)
    end

    private :trigger, :content, :chevron
  end
end
