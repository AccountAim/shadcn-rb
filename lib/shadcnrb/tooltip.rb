# frozen_string_literal: true

# shadcn divergence: the shared Stimulus `shadcnrb--anchored--component`
# controller replaces Base UI `Tooltip.Root`. There is no `TooltipProvider` —
# `delay:` / `close_delay:` live on each root and default to shadcn's
# provider values (0/0). upstream: tooltip.tsx.
#
# shadcn divergence: no portal. The panel is a `popover="manual"` element
# shown in the top layer and positioned by @floating-ui/dom (offset, flip,
# shift, arrow) through the shared controller. See
# anchored/component_controller.js.
#
# shadcn divergence: no `TooltipContent` part — the block body *is* the
# panel, and `trigger` is the only slot. `trigger` is orphan-protected: it
# only renders through a `:tooltip` `Shadcnrb::Scope` yielded by
# `sui.tooltip do |t| ... end`.

module Shadcnrb
  class Tooltip < Component
    include Shadcnrb::Anchored::Component

    # The block is the panel; `t.trigger` names what it's attached to.
    # `sui.hover_card` takes the same shape.
    #
    #   sui.tooltip do |t|
    #     t.trigger { sui.button "Save" }
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
    # `form:`). A disabled trigger still shows its panel — hover lives on the
    # root, so no `<span>` wrapper like upstream needs.
    def tooltip(side: :top, align: :center, arrow: true,
      delay: 0, close_delay: 0, content: {}, **opts, &block)
      opts = anchored_root(opts, slot: "tooltip",
        delay:, close_delay:, describe: true)
      scope = Scope.new(@builder, kind: :tooltip, component: self)
      content_tag(:div, **opts) do
        trigger_html, body = capture_parts(scope, &block)
        safe_join([ trigger_html, panel(body, side:, align:, arrow:, **content) ])
      end
    end

    private

    def panel(body, side:, align:, arrow:, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.content, opts[:class])
      opts[:role] ||= "tooltip"
      opts = anchored_panel(opts, slot: "tooltip-content", side:, align:)
      content_tag(:div, **opts) do
        arrow ? safe_join([ body, arrow_tag ]) : body
      end
    end

    def arrow_tag
      tag.span("", class: self.class.style.arrow,
        data: { slot: "tooltip-arrow" }, aria: { hidden: true })
    end
  end
end
