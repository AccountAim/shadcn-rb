# frozen_string_literal: true

# shadcn divergence: the shared Stimulus `shadcnrb--anchored--component`
# controller replaces Base UI `PreviewCard.Root`. `delay:` / `close_delay:`
# live on the root rather than the trigger, keeping the timing in one place;
# the defaults (600ms / 300ms) match upstream. upstream: hover-card.tsx.
#
# shadcn divergence: no floating-ui. The panel is a `popover="manual"`
# element shown in the top layer and positioned by the shared controller —
# it offsets, flips, and shifts like upstream, minus the finer middleware.
# See anchored/component_controller.js.
#
# shadcn divergence: no `HoverCardContent` part — the block body *is* the
# panel, and `trigger` is the only slot. `trigger` is orphan-protected: it
# only renders through a `:hover_card` `Shadcnrb::Scope` yielded by
# `sui.hover_card do |h| ... end`.

module Shadcnrb
  class HoverCard < Component
    include Shadcnrb::Anchored::Component

    # The block is the panel; `h.trigger` names what it's attached to.
    # `sui.tooltip` takes the same shape.
    #
    #   sui.hover_card do |h|
    #     h.trigger { sui.link_to "@shadcn", user_path(user) }
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
      opts = anchored_root(opts, slot: "hover-card", delay:, close_delay:)
      scope = Scope.new(@builder, kind: :hover_card, component: self)
      content_tag(:div, **opts) do
        trigger_html, body = capture_parts(scope, &block)
        safe_join([ trigger_html, panel(body, side:, align:, **content) ])
      end
    end

    private

    def panel(body, side:, align:, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.content, opts[:class])
      opts = anchored_panel(opts, slot: "hover-card-content", side:, align:)
      content_tag(:div, body, **opts)
    end
  end
end
