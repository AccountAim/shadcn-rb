# frozen_string_literal: true

# shadcn divergence: a CSS grid with ARIA table roles, not a `<table>`.
# Column tracks come from the columns — `columns:` on `sui.data_grid`, or the
# attributes on each `g.head` — and sit on the table as `--cols`. Below a
# 36rem container width each row is a two-column card placed by the columns'
# `card:`; above it rows are subgrids of the table, so cells line up.
#
# Column attributes: `width:` sizes like a flex item — `:auto` (default),
# `:fit`, an Integer share, a String length — with `min:` / `max:`; flexible
# columns truncate unless `wrap: true`. `align: :end`, `fixed: true` (the
# first column pins at the start, any other at the end), `card: :title |
# :aside | :footer | false`, `order:`, `heading: false`.
#
# shadcn divergence: child parts (`header`, `body`, `footer`, `row`, `head`,
# `cell`, `caption`) are orphan-protected — they only render through a
# `:data_grid`-kind `Shadcnrb::Scope` (`sui.data_grid do |g| ... end`, or
# `sui.data_grid_proxy` for rows rendered on their own, e.g. a Turbo stream
# appending to the body). Each heading carries its column's cell classes and
# label as data, and data_grid/component_controller.js stamps them onto rows
# that arrive later, so those need no column knowledge.
#
# shadcn divergence: `g.header fixed: true` renders header, body and footer
# as separate grids so the body alone scrolls, kept in step by
# data_grid/component_controller.js; call it before `g.body`. With `columns:` a
# bare `g.header fixed: true` renders the heads itself. `selectable: true`
# makes it an ARIA grid:
# click or arrow keys move the selected cell, kept in view by the same
# controller.

module Shadcnrb
  class DataGrid < Component
    COLUMN_KEYS = %i[width min max wrap align fixed card order heading].freeze
    CONTROLLER = "shadcnrb--data-grid--component"

    def data_grid(columns: nil, selectable: false, size: :default, **opts, &block)
      style = self.class.style
      size_class = Shadcnrb::TailwindMerge.fetch_variant(
        style.sizes, size, kind: :size, component: "data_grid"
      )
      setup(columns, selectable, collect: true)
      scope = Scope.new(@builder, kind: :data_grid, component: self)
      capture(scope, &block) if block
      header(scope:) if @explicit && !@sections.key?(:header)

      base = @fixed ? style.fixed_base : style.base
      classes = [ base, size_class, (style.selectable if selectable), opts[:class] ]
      opts[:class] = Shadcnrb::TailwindMerge.call(*classes)
      data = { slot: "data-grid", size: size.to_s, cell_class: style.cell }
      opts[:data] = (opts[:data] || {}).merge(data)
      opts[:data][:selectable_class] = style.selectable_cell if selectable
      opts[:style] = [ opts[:style], "--cols: #{tracks}" ].compact.join("; ")
      opts[:role] = "table"
      if selectable
        opts[:role] = "grid"
        opts[:tabindex] = 0
        opts[:data][:action] = merge_action(opts[:data], "keydown->#{CONTROLLER}#navigate",
          "click->#{CONTROLLER}#select", "focus->#{CONTROLLER}#enter")
      end

      parts = @sections.values_at(:header, :body, :footer, :caption).compact
      table = content_tag(:div, safe_join(parts), **opts)

      container_data = { slot: "data-grid-container" }
      container_data[:controller] = CONTROLLER
      container_class = @fixed ? style.fixed_container : style.container
      content_tag(:div, table, class: container_class, data: container_data)
    ensure
      @sections = nil
    end

    def proxy(columns: nil)
      setup(columns, false, collect: false)
      Scope.new(@builder, kind: :data_grid, component: self)
    end

    def header(fixed: false, scope: nil, **opts, &block)
      @fixed = fixed
      block ||= proc { row(scope:) { safe_join(@columns.map { |c| head(c[:label], scope:) }) } }
      group(:header, "data-grid-header", opts) { scope.capture_block(&block) }
    end

    def body(scope: nil, **opts, &block)
      if @fixed
        action = merge_action(opts[:data], "scroll->#{CONTROLLER}#pan")
        opts[:data] = { **(opts[:data] || {}), action: }
      end

      group(:body, "data-grid-body", opts) { scope.capture_block(&block) }
    end

    def footer(scope: nil, **opts, &block)
      group(:footer, "data-grid-footer", opts) { scope.capture_block(&block) }
    end

    def caption(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.caption, opts[:class])
      opts[:data] = slot_data(opts[:data], "data-grid-caption")
      html = content_tag(:div, role: "caption", **opts) { block ? capture(&block) : name.to_s }
      section(:caption, html)
    end

    def row(scope: nil, **opts, &block)
      @cell_index = 0
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.row, opts[:class])
      opts[:data] = slot_data(opts[:data], "data-grid-row")
      html = content_tag(:div, role: "row", **opts) { scope.capture_block(&block) }
      @width = [ @width, @cell_index ].max
      html
    end

    def head(name = nil, label: name, scope: nil, **opts, &block)
      attrs = opts.extract!(*COLUMN_KEYS).merge(label: label&.to_s)
      column = column_at(@cell_index, normalize(attrs, @cell_index))
      @cell_index += 1
      classes = [ self.class.style.head, *head_classes(column), opts[:class] ]
      opts[:class] = Shadcnrb::TailwindMerge.call(*classes)
      cell_class = [ self.class.style.cell, *column_cell_classes(column) ]
      cell_class << self.class.style.selectable_cell if @selectable
      opts[:data] = slot_data(opts[:data], "data-grid-head").merge(
        label: column[:label], cell_class: Shadcnrb::TailwindMerge.call(*cell_class),
        truncate: (true if truncates?(column))
      )
      content_tag(:div, role: "columnheader", **opts) { block ? capture(&block) : name.to_s }
    end

    # `colspan:` is an Integer or `:all`. Spans narrower than the table are
    # inline `grid-column`, so they only make sense in grid layout.
    # `selectable: false` keeps a cell out of the selection in a selectable
    # table: not focusable, and the keys skip it.
    def cell(name = nil, colspan: nil, selectable: true, scope: nil, **opts, &block)
      style = self.class.style
      # A spanning cell is its own thing, not a value of the first column it covers.
      column = colspan ? {} : (@columns[@cell_index] || {})
      @cell_index += colspan.is_a?(Integer) ? colspan : 1
      # An unknown column (rows rendered through the proxy) gets the base classes
      # only; the controller stamps the column's from the heading.
      classes = [ style.cell, *(column_cell_classes(column) unless column.empty?), opts[:class] ]
      classes << style.selectable_cell if @selectable && selectable
      opts[:class] = Shadcnrb::TailwindMerge.call(*classes)
      opts[:data] = slot_data(opts[:data], "data-grid-cell").merge(label: column[:label])
      opts[:data][:selectable] = false unless selectable
      opts[:role] = @selectable ? "gridcell" : "cell"
      opts[:tabindex] = -1 if @selectable && selectable
      styles = [ opts[:style] ]
      styles << "--card-order: #{column[:order]}" if column[:order]
      if colspan == :all || (colspan.is_a?(Integer) && !@columns.empty? && colspan >= @columns.size)
        opts[:class] += " @xl:col-span-full"
      elsif colspan
        styles << "grid-column: span #{colspan}"
      end

      opts[:style] = styles.compact.join("; ").presence
      opts[:title] = name.to_s if truncates?(column) && !block
      content_tag(:div, block ? capture(&block) : name.to_s, **opts)
    end

    private :header, :body, :footer, :row, :head, :cell, :caption

    private

    # `collect:` gathers the parts into sections for `table` to place; the
    # proxy emits them straight away.
    def setup(columns, selectable, collect:)
      @fixed = false
      @selectable = selectable
      @explicit = !columns.nil?
      @columns = Array(columns).each_with_index.map do |c, i|
        normalize(c.is_a?(Hash) ? c.symbolize_keys : { label: c.to_s }, i)
      end
      @sections = collect ? {} : nil
      @cell_index = 0
      @width = 0
    end

    # `fixed: true` becomes the side to pin: the first column at the start,
    # any other at the end.
    def normalize(column, index)
      return column unless column.delete(:fixed)

      column.merge(pin: index.zero? ? :start : :end)
    end

    # Explicit columns win; otherwise each `g.head` registers its column.
    def column_at(index, attrs)
      return @columns[index] || {} if @explicit

      @columns[index] ||= attrs
    end

    # `:fit` → max-content, 2 → minmax(min, 2fr), "6rem" → 6rem, else auto.
    # `max:` caps `:auto` and `:fit`; a flexible column has no cap.
    def tracks
      columns = @columns.empty? ? Array.new(@width) { {} } : @columns
      columns.map { |c|
        case c[:width]
        when Integer then "minmax(#{c[:min] || '8rem'}, #{c[:width]}fr)"
        when String  then c[:width]
        when :fit    then c[:max] ? "fit-content(#{c[:max]})" : "max-content"
        else c[:max] ? "minmax(auto, #{c[:max]})" : "auto"
        end
      }.join(" ")
    end

    def flexible?(column) = column[:width].is_a?(Integer)

    def truncates?(column) = flexible?(column) && !column[:wrap]

    def head_classes(column)
      style = self.class.style
      [
        (style.head_align_end if column[:align] == :end),
        (style.hidden_heading if column[:heading] == false),
        style.pins[column[:pin]]
      ]
    end

    # Everything a cell gets from its column; the heading carries the merged
    # result for rows that arrive later.
    def column_cell_classes(column)
      style = self.class.style
      card = column[:card] == false ? :hidden : (column[:card] || :default)
      [
        style.cards.fetch(card),
        (style.card_order if column[:order]),
        (style.flexible if flexible?(column)),
        (column[:wrap] ? style.wrap : style.nowrap),
        (style.truncate if truncates?(column)),
        (style.align_end if column[:align] == :end),
        style.pins[column[:pin]],
        (style.pin_hover if column[:pin])
      ].compact
    end

    def group(name, slot, opts, &block)
      style = self.class.style
      base = @fixed ? style.public_send(:"fixed_#{name}") : style.public_send(name)
      opts[:class] = Shadcnrb::TailwindMerge.call(base, opts[:class])
      opts[:data] = slot_data(opts[:data], slot)
      opts[:data]["#{CONTROLLER}-target"] = name.to_s if @fixed
      section(name, content_tag(:div, role: "rowgroup", **opts, &block))
    end

    def slot_data(data, slot) = (data || {}).merge(slot:)

    def section(name, html)
      return html unless @sections

      @sections[name] = html
      "".html_safe
    end
  end
end
