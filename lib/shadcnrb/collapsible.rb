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
    #
    # `content:` are default options for `c.content`. The overlay kwargs
    # (`dropdown_menu:`, `dialog:`, ...) wrap the whole collapsible as that
    # overlay's trigger, like `sui.button` — with `dropdown_menu: { panel: }`
    # naming the content's id, the same list doubles as a flyout:
    #
    #   sui.collapsible open: true, content: { id: "docs" },
    #                   dropdown_menu: { panel: "docs", side: :right } do |c|
    def collapsible(open: false, content: {}, **opts, &block)
      overlay = extract_overlay!(opts)
      state = open ? "open" : "closed"
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(
        slot: "collapsible",
        state:,
        controller: [ "shadcnrb--collapsible--component", opts.dig(:data, :controller) ].compact.join(" "),
        "shadcnrb--collapsible--component-open-value": open.to_s
      )
      html = content_tag(:div, **opts) do
        block ? with_current(state, content) { capture(proxy, &block) } : "".html_safe
      end

      wrap_overlay(overlay, html)
    end

    # Bare scope for rendering parts outside a `sui.collapsible` block —
    # e.g. a chevron stamped onto a trigger in a sibling scope.
    def proxy
      Scope.new(@builder, kind: :collapsible, component: self)
    end

    # Layout-neutral wrapper (`display: contents`) that makes your markup the
    # toggle — rendered in place, since a disclosure trigger usually sits
    # inside surrounding chrome:
    #
    #   c.trigger { sui.button variant: :ghost, size: :"icon-sm" { c.chevron } }
    #
    # Or skip it and stamp the toggle onto an existing element directly, like
    # `s.menu_button collapsible: true` does.
    def trigger(scope: nil, &block)
      content_tag(:span,
        class: "contents",
        data: { slot: "collapsible-trigger",
                action: "click->shadcnrb--collapsible--component#toggle" }) do
        scope ? scope.capture_block(&block) : capture(&block)
      end
    end

    def content(scope: nil, **opts, &block)
      state, defaults = @current || [ "closed", {} ]
      opts = defaults.except(:class).merge(opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.content,
        defaults[:class], opts[:class])
      opts[:data] = (opts[:data] || {}).merge(
        slot: "collapsible-content",
        "shadcnrb--collapsible--component-target": "content",
        state:
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

    private

    # Saved and restored around the block so a nested collapsible doesn't
    # leak its state or content defaults into the outer one's parts.
    def with_current(state, content)
      outer, @current = @current, [ state, content ]
      yield
    ensure
      @current = outer
    end
  end
end
