# frozen_string_literal: true

# shadcn divergence: child parts (`header`, `media`, `title`, `description`,
# `content`) are orphan-protected — they only render when called through an
# `:empty`-kind `Shadcnrb::Scope` (yielded by `sui.empty do |e| ... end`, or
# via `sui.empty_proxy`).

module Shadcnrb
  class Empty < Component
    def empty(**opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
      opts[:"data-slot"] = "empty"
      content_tag(:div, **opts) do
        block ? capture(proxy, &block) : "".html_safe
      end
    end

    def proxy
      Scope.new(@builder, kind: :empty, component: self)
    end

    def header(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.header, opts[:class])
      opts[:"data-slot"] = "empty-header"
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def media(variant: :default, scope: nil, **opts, &block)
      variant_class = Shadcnrb::TailwindMerge.fetch_variant(self.class.style.media_variants,
        variant, kind: :variant, component: "Empty")
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.media_base, variant_class, opts[:class])
      opts[:"data-slot"] = "empty-icon"
      opts[:"data-variant"] = variant.to_s
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def title(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.title, opts[:class])
      opts[:"data-slot"] = "empty-title"
      content_tag(:div, **opts) { block ? capture(&block) : name.to_s }
    end

    def description(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.description, opts[:class])
      opts[:"data-slot"] = "empty-description"
      content_tag(:div, **opts) { block ? capture(&block) : name.to_s }
    end

    def content(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.content, opts[:class])
      opts[:"data-slot"] = "empty-content"
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    private :header, :media, :title, :description, :content
  end
end
