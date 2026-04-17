# frozen_string_literal: true

# shadcn divergence: child parts (`header`, `title`, `description`, `action`,
# `content`, `footer`) are orphan-protected — they only render when called
# through a `:card`-kind `Shadcnrb::Scope` (yielded by `sui.card do |c| ... end`,
# or via `sui.card_proxy`).

module Shadcnrb
  class Card < Component
    def card(**opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "card")
      content_tag(:div, **opts) do
        block ? capture(proxy, &block) : "".html_safe
      end
    end

    def proxy
      Scope.new(@builder, kind: :card, component: self)
    end

    def header(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.header, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "card-header")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def title(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.title, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "card-title")
      content_tag(:div, **opts) { block ? capture(&block) : name.to_s }
    end

    def description(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.description, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "card-description")
      content_tag(:div, **opts) { block ? capture(&block) : name.to_s }
    end

    def action(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.action, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "card-action")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def content(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.content, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "card-content")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def footer(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.footer, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "card-footer")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    private :header, :title, :description, :action, :content, :footer
  end
end
