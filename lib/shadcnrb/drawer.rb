# frozen_string_literal: true

# shadcn divergence: our `drawer` maps to shadcn's `Sheet` (side-anchored);
# shadcn's separate `drawer.tsx` (bottom-sheet powered by vaul) isn't ported —
# vaul is a heavyweight React-only lib. upstream: sheet.tsx.
#
# Upstream's Sheet is Dialog with side classes, and so is this: `Dialog`
# supplies the trigger slot, backdrop, panel, lazy-loading, parts and
# controller under the `drawer` slot name; only the panel classes differ.

module Shadcnrb
  class Drawer < Dialog
    # The block is the drawer panel; `d.trigger` names what opens it — the
    # same slot shape as dialog. Click lives on the root (clicks inside the
    # panel or backdrop are filtered out by the controller), so the trigger
    # markup is used verbatim.
    #
    #   sui.drawer side: :left do |d|
    #     d.trigger { sui.button "Settings", variant: :outline }
    #     d.header do
    #       d.title "Settings"
    #     end
    #     ...
    #   end
    #
    # `**opts` land on the root; `content:` is the panel's own option hash.
    # `open: true` starts open (server-driven drawers omit the trigger);
    # `src:` / `reload:` / `loading:` lazy-load the panel via a Turbo Frame
    # — same contract as `sui.dialog`.
    def drawer(side: :right, open: false, src: nil, reload: false, loading: nil,
      content: {}, **opts, &block)
      modal(panel_class(side), open:, src:, reload:, loading:, content:, **opts, &block)
    end

    # Inherited public entry point; `d.dialog` inside a drawer block must
    # reach the builder's dialog, not render a drawer-slotted one.
    undef_method :dialog

    private

    def slot = "drawer"

    def panel_class(side)
      style = self.class.style
      Shadcnrb::TailwindMerge.call(
        style.content_base,
        Shadcnrb::TailwindMerge.fetch_variant(style.sides, side, kind: :side, component: "Drawer")
      )
    end
  end
end
