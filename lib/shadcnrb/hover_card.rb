# frozen_string_literal: true

# shadcn divergence: Stimulus `shadcnrb--hover-card--component` controller
# replaces Base UI `PreviewCard.Root`. `delay:` / `close_delay:` live on the
# root rather than the trigger, keeping the timing in one place; the defaults
# (600ms / 300ms) match upstream. upstream: hover-card.tsx.
#
# shadcn divergence: no floating-ui. The panel is absolutely positioned inside
# a `relative` root through the `side:` / `align:` class tables, so it never
# flips near a viewport edge — pick a side that fits. `sideOffset` /
# `alignOffset` are baked in at 4px; override with `content: { class: ... }`.
#
# shadcn divergence: no `HoverCardContent` part — the block body *is* the
# panel, and `trigger` is the only slot. `trigger` is orphan-protected: it
# only renders through a `:hover_card` `Shadcnrb::Scope` yielded by
# `sui.hover_card do |h| ... end`.

module Shadcnrb
  class HoverCard < Component
    SIDES_ON_Y_AXIS = %i[top bottom].freeze

    # The block is the panel; `h.trigger` names what it's attached to.
    # `sui.tooltip` takes the same shape.
    #
    #   sui.hover_card do |h|
    #     h.trigger "@shadcn", user_path(user)
    #     tag.p "The React Framework – created and maintained by @vercel."
    #   end
    #
    #   sui.hover_card side: :right do |h|
    #     h.trigger { sui.avatar { |a| a.fallback "SC" } }
    #     tag.p "Last seen 4 minutes ago."
    #   end
    #
    # `delay:` / `close_delay:` are milliseconds before the panel opens on
    # hover / closes after the pointer leaves. `**opts` land on the root;
    # `content:` is the panel's own option hash (same idea as `button_to`'s
    # `form:`).
    def hover_card(side: :bottom, align: :center,
      delay: 600, close_delay: 300, content: {}, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(
        slot: "hover-card",
        state: "closed",
        controller: [ "shadcnrb--hover-card--component",
                      opts.dig(:data, :controller) ].compact.join(" "),
        action: merge_action(opts[:data],
          "mouseenter->shadcnrb--hover-card--component#open",
          "mouseleave->shadcnrb--hover-card--component#close",
          "focusin->shadcnrb--hover-card--component#open",
          "focusout->shadcnrb--hover-card--component#close",
          "keydown.esc@window->shadcnrb--hover-card--component#dismiss"),
        "shadcnrb--hover-card--component-delay-value": delay,
        "shadcnrb--hover-card--component-close-delay-value": close_delay
      )
      scope = Scope.new(@builder, kind: :hover_card, component: self)
      content_tag(:div, **opts) do
        trigger_html, body = capture_parts(scope, &block)
        safe_join([ trigger_html, panel(body, side:, align:, **content) ])
      end
    end

    # Marks which part of the block is the trigger — the rest is the panel.
    # Your markup is used verbatim, so every helper keeps its own signature
    # and the component pulls in no dependencies of its own:
    #
    #   h.trigger { sui.link_to "@shadcn", user_path(user) }
    #   h.trigger { sui.badge "Pro", variant: :secondary }
    #
    # Returns nothing — `hover_card` hoists the markup to the top of the root,
    # so this can sit anywhere in the block. Hover lives on the root, so the
    # trigger element itself is left untouched.
    def trigger(scope: nil, &block)
      @trigger_html = block ? capture(&block) : "".html_safe
      "".html_safe
    end

    private

    # Splits one pass over the block into (trigger slot, panel body). The
    # ivar is saved and restored so a card rendered inside another card's
    # panel doesn't steal the outer trigger.
    def capture_parts(scope, &block)
      return [ "".html_safe, "".html_safe ] unless block

      outer, @trigger_html = @trigger_html, nil
      body = capture(scope, &block)
      slot = @trigger_html || "".html_safe
      @trigger_html = outer
      [ slot, body ]
    end

    def panel(body, side:, align:, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(
        self.class.style.content, *placement(side, align), opts[:class]
      )
      opts[:data] = (opts[:data] || {}).merge(
        slot: "hover-card-content",
        side: side.to_s,
        align: align.to_s,
        state: "closed",
        "shadcnrb--hover-card--component-target": "content"
      )
      content_tag(:div, body, **opts)
    end

    # Alignment shifts along the axis the side doesn't occupy, so top/bottom
    # align on x and left/right on y.
    def placement(side, align)
      style = self.class.style
      align_table = SIDES_ON_Y_AXIS.include?(side.to_sym) ? style.align_x : style.align_y
      [
        Shadcnrb::TailwindMerge.fetch_variant(style.sides, side.to_sym,
          kind: :side, component: "hover_card"),
        Shadcnrb::TailwindMerge.fetch_variant(align_table, align.to_sym,
          kind: :align, component: "hover_card")
      ]
    end

    private :trigger
  end
end
