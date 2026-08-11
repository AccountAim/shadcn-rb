# frozen_string_literal: true

module Shadcnrb
  module Anchored
    # The trigger-slot mechanics shared by every trigger+panel component:
    # `trigger` stashes caller markup, `capture_parts` splits one block pass
    # into (trigger slot, rest of body). Anchored overlays get it via
    # `Anchored::Component`; modal components (dialog, drawer) include it
    # directly.
    module TriggerSlot
      # Marks which part of the block is the trigger — the rest is the panel.
      # Your markup is used verbatim, so every helper keeps its own signature
      # and the component pulls in no dependencies of its own:
      #
      #   t.trigger { sui.button "Save", variant: :ghost }
      #   d.trigger { sui.link_to "Edit", "#" }
      #
      # Returns nothing — the wrapper hoists the markup to the top of the
      # root, so this can sit anywhere in the block. The opening interaction
      # lives on the root, so the trigger element itself is left untouched.
      def trigger(scope: nil, &block)
        @trigger_html = block ? capture(&block) : "".html_safe
        "".html_safe
      end

      private :trigger

      private

      # Splits one pass over the block into (trigger slot, panel body). The
      # ivar is saved and restored so a component rendered inside another's
      # panel doesn't steal the outer trigger.
      def capture_parts(scope, &block)
        return [ "".html_safe, "".html_safe ] unless block

        outer, @trigger_html = @trigger_html, nil
        body = capture(scope, &block)
        slot = @trigger_html || "".html_safe
        @trigger_html = outer
        [ slot, body ]
      end
    end
  end
end
