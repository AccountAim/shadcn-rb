# frozen_string_literal: true

module Shadcnrb
  module Anchored
    # Shared plumbing for overlays anchored to a trigger (tooltip,
    # hover_card): the `trigger` slot, the block split, and the root/panel
    # wiring for the shared `shadcnrb--anchored--component` controller.
    # The including `Shadcnrb::Component` subclass supplies the `root` /
    # `content` styles and the public wrapper method.
    module Component
      include Shadcnrb::Anchored::TriggerSlot

      SIDES  = %i[top bottom left right].freeze
      ALIGNS = %i[start center end].freeze

      private

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
      # `controller:` targets a subclassed engine (dropdown_menu,
      # navigation_menu) instead of the shared one.
      def anchored_panel(opts, slot:, side:, align:,
        controller: "shadcnrb--anchored--component")
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
          "#{controller}-target": "content"
        )
        opts
      end
    end
  end
end
