# frozen_string_literal: true

# shadcn divergence: child parts (`header`, `body`, `footer`, `row`, `head`,
# `cell`, `caption`) are orphan-protected — they only render when called
# through a `:table`-kind `Shadcnrb::Scope` (yielded by `sui.table do |t| ... end`,
# or via `sui.table_proxy`).
#
# shadcn divergence: `fixed_header: true` renders header and body as two
# tables — the header outside the scrolling body — kept in step by
# table/component_controller.js. Both reserve a stable scrollbar gutter so
# their columns stay aligned. The header part — the `thead`, or the header
# container in fixed mode — is `data-slot="table-header"` and draws the
# header rule; the body part is `table-body` likewise. `size:` (`:default`,
# `:lg`) sets row height and padding through descendant selectors on the
# table, so the parts stay size-agnostic.

module Shadcnrb
  class Table < Component
    def table(fixed_header: false, size: :default, **opts, &block)
      style = self.class.style
      size_class = Shadcnrb::TailwindMerge.fetch_variant(
        style.sizes, size, kind: :size, component: "table"
      )

      table_class = Shadcnrb::TailwindMerge.call(style.base, size_class, opts.delete(:class))
      opts[:data] = (opts[:data] || {}).merge(slot: "table", size: size.to_s)
      scope = Scope.new(@builder, kind: :table, component: self)
      return fixed_header_table(table_class, opts, scope, &block) if fixed_header

      plain_table(table_class, opts, scope, &block)
    end

    def proxy
      Scope.new(@builder, kind: :table, component: self)
    end

    def header(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.header, opts[:class])
      opts[:data] = slot_data(opts[:data], "table-header")
      section(:header, content_tag(:thead, **opts) { scope.capture_block(&block) })
    end

    def body(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.body, opts[:class])
      opts[:data] = slot_data(opts[:data], "table-body")
      section(:body, content_tag(:tbody, **opts) { scope.capture_block(&block) })
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

    private

    def plain_table(table_class, opts, scope, &block)
      container_opts = { class: self.class.style.container, data: { slot: "table-container" } }
      content_tag(:div, **container_opts) do
        content_tag(:table, class: table_class, **opts) do
          block ? capture(scope, &block) : "".html_safe
        end
      end
    end

    # The block's header and body are collected rather than emitted, then
    # placed in their own tables: the header table is fixed-layout so the
    # controller's column widths hold.
    def fixed_header_table(table_class, opts, scope, &block)
      @sections = {}
      capture(scope, &block)
      header, body = @sections.values_at(:header, :body)
      @sections = nil

      style = self.class.style
      header_data = { slot: "table-header", "shadcnrb--table--component-target": "header" }
      body_data = { slot: "table-body", "shadcnrb--table--component-target": "body",
                    action: "scroll->shadcnrb--table--component#pan" }
      container_data = { slot: "table-container", controller: "shadcnrb--table--component" }
      content_tag(:div, class: style.fixed_container, data: container_data) do
        safe_join([
          content_tag(:div, class: style.fixed_header, data: header_data) do
            content_tag(:table, header, class: "#{table_class} table-fixed", **opts)
          end,
          content_tag(:div, class: style.fixed_body, data: body_data) do
            content_tag(:table, body, class: table_class, **opts)
          end
        ])
      end
    end

    # In fixed mode the containers are the header and body parts, so the row
    # groups stay unnamed.
    def slot_data(data, slot) = @sections ? data : (data || {}).merge(slot:)

    def section(name, html)
      return html unless @sections

      @sections[name] = html
      "".html_safe
    end
  end
end
