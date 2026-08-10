# frozen_string_literal: true

module Shadcnrb
  module Anchored
    # Shared plumbing for overlays anchored to a trigger (tooltip,
    # hover_card): the `trigger` slot, the block split, and the root/panel
    # wiring for the shared `shadcnrb--anchored--component` controller.
    # The including `Shadcnrb::Component` subclass supplies the `root` /
    # `content` styles and the public wrapper method.
    module Component
      SIDES  = %i[top bottom left right].freeze
      ALIGNS = %i[start center end].freeze

      # Marks which part of the block is the trigger — the rest is the panel.
      # Your markup is used verbatim, so every helper keeps its own signature
      # and the component pulls in no dependencies of its own:
      #
      #   t.trigger { sui.button "Save", variant: :ghost }
      #   h.trigger { sui.link_to "@shadcn", user_path(user) }
      #
      # Returns nothing — the wrapper hoists the markup to the top of the
      # root, so this can sit anywhere in the block. Hover lives on the root,
      # so the trigger element itself is left untouched.
      def trigger(scope: nil, &block)
        @trigger_html = block ? capture(&block) : "".html_safe
        "".html_safe
      end

      private :trigger

      private

      # Splits one pass over the block into (trigger slot, panel body). The
      # ivar is saved and restored so an overlay rendered inside another
      # overlay's panel doesn't steal the outer trigger.
      def capture_parts(scope, &block)
        return [ "".html_safe, "".html_safe ] unless block

        outer, @trigger_html = @trigger_html, nil
        body = capture(scope, &block)
        slot = @trigger_html || "".html_safe
        @trigger_html = outer
        [ slot, body ]
      end

      # Root options: hover/focus/Esc handlers and delay values for the
      # shared controller. `describe:` asks it to mint `aria-describedby`
      # between trigger and panel (tooltip).
      def anchored_root(opts, slot:, delay:, close_delay:, describe: false)
        opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
        opts[:data] = (opts[:data] || {}).merge(
          slot: slot,
          state: "closed",
          controller: [ "shadcnrb--anchored--component",
                        opts.dig(:data, :controller) ].compact.join(" "),
          action: merge_action(opts[:data],
            "mouseenter->shadcnrb--anchored--component#open",
            "mouseleave->shadcnrb--anchored--component#close",
            "focusin->shadcnrb--anchored--component#open",
            "focusout->shadcnrb--anchored--component#close",
            "keydown.esc@window->shadcnrb--anchored--component#dismiss"),
          "shadcnrb--anchored--component-delay-value": delay,
          "shadcnrb--anchored--component-close-delay-value": close_delay
        )

        opts[:data][:"shadcnrb--anchored--component-describe-value"] = true if describe
        opts
      end

      # Panel options: `popover="manual"` renders it in the top layer when
      # shown, so no ancestor `overflow` or stacking context can clip it. The
      # controller computes fixed coordinates from `data-side` / `data-align`
      # (and may rewrite `data-side` when it flips near a viewport edge).
      def anchored_panel(opts, slot:, side:, align:)
        raise ArgumentError, "Unknown side #{side.inspect}. Valid: #{SIDES.inspect}" unless
          SIDES.include?(side.to_sym)
        raise ArgumentError, "Unknown align #{align.inspect}. Valid: #{ALIGNS.inspect}" unless
          ALIGNS.include?(align.to_sym)

        opts[:popover] = "manual"
        opts[:data] = (opts[:data] || {}).merge(
          slot: slot,
          side: side.to_s,
          align: align.to_s,
          state: "closed",
          "shadcnrb--anchored--component-target": "content"
        )
        opts
      end
    end
  end
end
