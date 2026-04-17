# frozen_string_literal: true

# shadcn divergence: child parts (`list`, `item`, `link`, `page`, `separator`,
# `ellipsis`) are orphan-protected — they only render when called through a
# `:breadcrumb`-kind `Shadcnrb::Scope` (yielded by `sui.breadcrumb do |bc| ... end`,
# or via `sui.breadcrumb_proxy` for standalone).

module Shadcnrb
  class Breadcrumb < Component
    def breadcrumb(**opts, &block)
      opts[:"aria-label"] ||= "breadcrumb"
      opts[:"data-slot"] = "breadcrumb"
      content_tag(:nav, **opts) do
        block ? capture(proxy, &block) : "".html_safe
      end
    end

    def proxy
      Scope.new(@builder, kind: :breadcrumb, component: self)
    end

    def list(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.list, opts[:class])
      opts[:"data-slot"] = "breadcrumb-list"
      content_tag(:ol, **opts) { scope.capture_block(&block) }
    end

    def item(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.item, opts[:class])
      opts[:"data-slot"] = "breadcrumb-item"
      content_tag(:li, **opts) { scope.capture_block(&block) }
    end

    # Shortcut form renders `<a>` via Rails `link_to`. Block form renders a
    # wrapper `<span>` — consumer supplies the interactive element (e.g. a
    # plain `link_to` / `button_to`) and inherits the styling.
    def link(name = nil, options = nil, icon: nil, scope: nil, **html_opts, &block)
      html_opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.link, html_opts[:class])
      html_opts[:"data-slot"] = "breadcrumb-link"
      if block
        content_tag(:span, **html_opts) { scope.capture_block(&block) }
      else
        scope.child_scope.link_to(name, options, icon:, **html_opts)
      end
    end

    def page(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.page, opts[:class])
      opts[:"data-slot"] = "breadcrumb-page"
      opts[:role] = "link"
      opts[:"aria-disabled"] = "true"
      opts[:"aria-current"] = "page"
      content_tag(:span, **opts) { block ? capture(&block) : name.to_s }
    end

    def separator(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.separator, opts[:class])
      opts[:"data-slot"] = "breadcrumb-separator"
      opts[:role] = "presentation"
      opts[:"aria-hidden"] = "true"
      content_tag(:li, **opts) { block ? capture(&block) : icon(:"chevron-right") }
    end

    def ellipsis(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.ellipsis, opts[:class])
      opts[:"data-slot"] = "breadcrumb-ellipsis"
      opts[:role] = "presentation"
      opts[:"aria-hidden"] = "true"
      content_tag(:span, **opts) do
        if block
          capture(&block)
        else
          safe_join([ icon(:ellipsis, class: "size-4"), tag.span("More", class: "sr-only") ])
        end
      end
    end

    private :list, :item, :link, :page, :separator, :ellipsis
  end
end
