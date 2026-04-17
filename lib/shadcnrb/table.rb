# frozen_string_literal: true

# shadcn divergence: child parts (`header`, `body`, `footer`, `row`, `head`,
# `cell`, `caption`) are orphan-protected — they only render when called
# through a `:table`-kind `Shadcnrb::Scope` (yielded by `sui.table do |t| ... end`,
# or via `sui.table_proxy`).

module Shadcnrb
  class Table < Component
    def table(**opts, &block)
      table_class = Shadcnrb::TailwindMerge.call(self.class.style.base, opts.delete(:class))
      opts[:data] = (opts[:data] || {}).merge(slot: "table")
      container_opts = { class: self.class.style.container, data: { slot: "table-container" } }
      scope = Scope.new(@builder, kind: :table, component: self)
      content_tag(:div, **container_opts) do
        content_tag(:table, class: table_class, **opts) do
          block ? capture(scope, &block) : "".html_safe
        end
      end
    end

    def proxy
      Scope.new(@builder, kind: :table, component: self)
    end

    def header(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.header, opts[:class])
      content_tag(:thead, **opts) { scope.capture_block(&block) }
    end

    def body(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.body, opts[:class])
      content_tag(:tbody, **opts) { scope.capture_block(&block) }
    end

    def footer(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.footer, opts[:class])
      content_tag(:tfoot, **opts) { scope.capture_block(&block) }
    end

    def row(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.row, opts[:class])
      content_tag(:tr, **opts) { scope.capture_block(&block) }
    end

    def head(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.head, opts[:class])
      content_tag(:th, **opts) { block ? capture(&block) : name.to_s }
    end

    def cell(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.cell, opts[:class])
      content_tag(:td, **opts) { block ? capture(&block) : name.to_s }
    end

    def caption(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.caption, opts[:class])
      content_tag(:caption, **opts) { block ? capture(&block) : name.to_s }
    end

    private :header, :body, :footer, :row, :head, :cell, :caption
  end
end
