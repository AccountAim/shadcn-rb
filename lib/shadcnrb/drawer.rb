# frozen_string_literal: true

# shadcn divergence: our `drawer` maps to shadcn's `Sheet` (side-anchored);
# shadcn's separate `drawer.tsx` (bottom-sheet powered by vaul) isn't ported —
# vaul is a heavyweight React-only lib. Stimulus `shadcnrb--drawer--component` controller
# replaces Radix Dialog. upstream: sheet.tsx.
#
# shadcn divergence: child parts (`trigger`, `content`, `header`, `title`,
# `description`, `footer`) are orphan-protected — they only render when called
# through a `:drawer`-kind `Shadcnrb::Scope` (yielded by `sui.drawer do |drawer| ... end`).

module Shadcnrb
  class Drawer < Component
    def drawer(**opts, &block)
      opts[:data] = (opts[:data] || {}).merge(slot: "drawer", controller: "shadcnrb--drawer--component")
      scope = Scope.new(@builder, kind: :drawer, component: self)
      content_tag(:div, **opts) do
        block ? capture(scope, &block) : "".html_safe
      end
    end

    def trigger(name = nil, variant: :default, size: :default, scope: nil, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(
        slot: "drawer-trigger",
        action: "click->shadcnrb--drawer--component#open"
      )
      button(name, variant:, size:, **opts, &block)
    end

    def content(side: :right, scope: nil, **opts, &block)
      style = self.class.style
      backdrop = tag.div("",
        data: { slot: "drawer-overlay", "shadcnrb--drawer--component-target": "backdrop",
                action: "click->shadcnrb--drawer--component#close" },
        class: style.backdrop
      )

      opts[:data] = (opts[:data] || {}).merge(slot: "drawer-content",
        "shadcnrb--drawer--component-target": "content")
      opts[:class] = Shadcnrb::TailwindMerge.call(
        style.content_base,
        Shadcnrb::TailwindMerge.fetch_variant(style.sides, side, kind: :side, component: "Drawer"),
        opts[:class]
      )

      panel = content_tag(:div, **opts) do
        body = scope.capture_block(&block)
        close_btn = button(
          variant: :ghost,
          size: :"icon-sm",
          "aria-label": "Close",
          class: style.close_btn_pos,
          data: { slot: "drawer-close", action: "click->shadcnrb--drawer--component#close" }
        ) { icon(:x) }
        safe_join([ body, close_btn ])
      end

      safe_join([ backdrop, panel ])
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

    private :trigger, :content, :header, :footer, :title, :description
  end
end
