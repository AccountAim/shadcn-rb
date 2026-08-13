# frozen_string_literal: true

# shadcn divergence: our `drawer` maps to shadcn's `Sheet` (side-anchored);
# shadcn's separate `drawer.tsx` (bottom-sheet powered by vaul) isn't ported —
# vaul is a heavyweight React-only lib. Stimulus `shadcnrb--drawer--component` controller
# replaces Radix Dialog. upstream: sheet.tsx.
#
# shadcn divergence: child parts (`header`, `title`, `description`, `footer`)
# are orphan-protected — they only render when called through a `:drawer`-kind
# `Shadcnrb::Scope` (yielded by `sui.drawer do |drawer| ... end`).

module Shadcnrb
  class Drawer < Component
    include Shadcnrb::Anchored::TriggerSlot

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
      opts[:data] = (opts[:data] || {}).merge(
        slot: "drawer",
        controller: [ "shadcnrb--drawer--component",
                      opts.dig(:data, :controller) ].compact.join(" "),
        action: merge_action(opts[:data],
          "click->shadcnrb--drawer--component#open",
          "keydown.esc@window->shadcnrb--drawer--component#close"),
        "shadcnrb--drawer--component-open-value": open
      )
      scope = Scope.new(@builder, kind: :drawer, component: self)
      content_tag(:div, **opts) do
        trigger_html, body = capture_parts(scope, &block)
        safe_join([ trigger_html, backdrop, panel(body, side:, src:, reload:, loading:, **content) ])
      end
    end

    private

    def backdrop
      tag.div("",
        data: { slot: "drawer-overlay", "shadcnrb--drawer--component-target": "backdrop",
                action: "click->shadcnrb--drawer--component#close" },
        class: self.class.style.backdrop
      )
    end

    def panel(body, side:, src:, reload:, loading:, **opts)
      style = self.class.style
      opts[:data] = (opts[:data] || {}).merge(slot: "drawer-content",
        "shadcnrb--drawer--component-target": "content")
      opts[:class] = Shadcnrb::TailwindMerge.call(
        style.content_base,
        Shadcnrb::TailwindMerge.fetch_variant(style.sides, side, kind: :side, component: "Drawer"),
        opts[:class]
      )

      content_tag(:div, **opts) do
        body = lazy_frame(body, src:, reload:, loading:, slot: "drawer") if src
        close_btn = button(
          variant: :ghost,
          size: :"icon-sm",
          "aria-label": "Close",
          class: style.close_btn_pos,
          data: { slot: "drawer-close", action: "click->shadcnrb--drawer--component#close" }
        ) { icon(:x) }
        safe_join([ body, close_btn ])
      end
    end

    def header(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.header, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "drawer-header")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def footer(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.footer, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "drawer-footer")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def title(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.title, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "drawer-title")
      content_tag(:h2, **opts) do
        block ? capture(&block) : name.to_s
      end
    end

    def description(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.description, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "drawer-description")
      content_tag(:p, **opts) do
        block ? capture(&block) : name.to_s
      end
    end

    private :header, :footer, :title, :description
  end
end
