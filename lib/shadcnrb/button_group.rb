# frozen_string_literal: true

# shadcn divergence: child parts (`separator`, `text`) are orphan-protected —
# they only render when called through a `:button_group`-kind `Shadcnrb::Scope`
# (yielded by `sui.button_group do |g| ... end`).

module Shadcnrb
  class ButtonGroup < Component
    def button_group(orientation: :horizontal, **opts, &block)
      opts[:class] = classes_from_style(
        self.class.style, variant: orientation, custom: opts[:class]
      )
      opts[:"data-slot"] = "button-group"
      opts[:"data-orientation"] = orientation.to_s
      opts[:role] = "group"
      content_tag(:div, **opts) do
        block ? capture(proxy, &block) : "".html_safe
      end
    end

    def proxy
      Scope.new(@builder, kind: :button_group, component: self)
    end

    def separator(scope: nil, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.separator, opts[:class])
      opts[:"data-slot"] = "button-group-separator"
      opts[:"data-orientation"] ||= "vertical"
      tag.div(**opts)
    end

    def text(name = nil, icon: nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.text, opts[:class])
      content_tag(:div, **opts) { content_with_icon(name, icon:, &block) }
    end

    private :separator, :text
  end
end
