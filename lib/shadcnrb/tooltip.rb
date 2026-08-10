# frozen_string_literal: true

# shadcn divergence: Stimulus `shadcnrb--tooltip--component` controller replaces
# Base UI `Tooltip.Root`. There is no `TooltipProvider` — `delay:` /
# `close_delay:` live on each root and default to shadcn's provider values
# (0/0). upstream: tooltip.tsx.
#
# shadcn divergence: no floating-ui. The panel is absolutely positioned inside
# a `relative` root through the `side:` / `align:` class tables, so it never
# flips or shifts near a viewport edge — pick a side that fits. `sideOffset` /
# `alignOffset` are baked in at 4px; override with `content: { class: ... }`.
#
# shadcn divergence: no `TooltipContent` part — the block body *is* the panel,
# and `trigger` is the only slot. `trigger` is orphan-protected: it only
# renders through a `:tooltip` `Shadcnrb::Scope` yielded by
# `sui.tooltip do |t| ... end`.

module Shadcnrb
  class Tooltip < Component
    SIDES_ON_Y_AXIS = %i[top bottom].freeze

    # The block is the panel; `t.trigger` names what it's attached to.
    # `sui.hover_card` takes the same shape.
    #
    #   sui.tooltip do |t|
    #     t.trigger "Save"
    #     "Add to library"
    #   end
    #
    #   sui.tooltip side: :right do |t|
    #     t.trigger { sui.button_to "Delete", record_path(r), method: :delete }
    #     "Deletes the record and its history"
    #   end
    #
    # `delay:` / `close_delay:` are milliseconds before the panel opens on
    # hover / closes after the pointer leaves. `**opts` land on the root;
    # `content:` is the panel's own option hash (same idea as `button_to`'s
    # `form:`).
    def tooltip(side: :top, align: :center, arrow: true,
      delay: 0, close_delay: 0, content: {}, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(
        slot: "tooltip",
        state: "closed",
        controller: [ "shadcnrb--tooltip--component",
                      opts.dig(:data, :controller) ].compact.join(" "),
        action: merge_action(opts[:data],
          "mouseenter->shadcnrb--tooltip--component#open",
          "mouseleave->shadcnrb--tooltip--component#close",
          "focusin->shadcnrb--tooltip--component#open",
          "focusout->shadcnrb--tooltip--component#close",
          "keydown.esc@window->shadcnrb--tooltip--component#dismiss"),
        "shadcnrb--tooltip--component-delay-value": delay,
        "shadcnrb--tooltip--component-close-delay-value": close_delay
      )
      scope = Scope.new(@builder, kind: :tooltip, component: self)
      content_tag(:div, **opts) do
        trigger_html, body = capture_parts(scope, &block)
        safe_join([ trigger_html, panel(body, side:, align:, arrow:, **content) ])
      end
    end

    # Marks which part of the block is the trigger — the rest is the panel.
    # Your markup is used verbatim, so every helper keeps its own signature
    # and the component pulls in no dependencies of its own:
    #
    #   t.trigger { sui.button "Save", variant: :ghost }
    #   t.trigger { sui.link_to "Docs", docs_path }
    #
    # Returns nothing — `tooltip` hoists the markup to the top of the root, so
    # this can sit anywhere in the block. Hover lives on the root, so a
    # disabled button still shows its panel (no `<span>` wrapper like upstream
    # needs). `aria-describedby` lands on the hoisted markup's first element,
    # or on whatever you tag `data-slot="tooltip-trigger"` yourself.
    def trigger(scope: nil, &block)
      @trigger_html = block ? capture(&block) : "".html_safe
      "".html_safe
    end

    private

    # Splits one pass over the block into (trigger slot, panel body). The
    # ivar is saved and restored so a tooltip rendered inside another
    # tooltip's panel doesn't steal the outer trigger.
    def capture_parts(scope, &block)
      return [ "".html_safe, "".html_safe ] unless block

      outer, @trigger_html = @trigger_html, nil
      body = capture(scope, &block)
      slot = @trigger_html || "".html_safe
      @trigger_html = outer
      [ slot, body ]
    end

    def panel(body, side:, align:, arrow:, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(
        self.class.style.content, *placement(side, align), opts[:class]
      )
      opts[:role] ||= "tooltip"
      opts[:data] = (opts[:data] || {}).merge(
        slot: "tooltip-content",
        side: side.to_s,
        align: align.to_s,
        state: "closed",
        "shadcnrb--tooltip--component-target": "content"
      )
      content_tag(:div, **opts) do
        arrow ? safe_join([ body, arrow_tag(side) ]) : body
      end
    end

    def arrow_tag(side)
      classes = Shadcnrb::TailwindMerge.fetch_variant(
        self.class.style.arrow_sides, side.to_sym, kind: :side, component: "tooltip"
      )
      tag.span("", class: Shadcnrb::TailwindMerge.call(self.class.style.arrow, classes),
        data: { slot: "tooltip-arrow" }, aria: { hidden: true })
    end

    # Alignment shifts along the axis the side doesn't occupy, so top/bottom
    # align on x and left/right on y.
    def placement(side, align)
      style = self.class.style
      align_table = SIDES_ON_Y_AXIS.include?(side.to_sym) ? style.align_x : style.align_y
      [
        Shadcnrb::TailwindMerge.fetch_variant(style.sides, side.to_sym,
          kind: :side, component: "tooltip"),
        Shadcnrb::TailwindMerge.fetch_variant(align_table, align.to_sym,
          kind: :align, component: "tooltip")
      ]
    end

    private :trigger
  end
end
