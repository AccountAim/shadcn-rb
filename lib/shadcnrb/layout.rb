# frozen_string_literal: true

module Shadcnrb
  class Layout < Component
    GAP = {
      0 => "gap-0", 1 => "gap-1", 2 => "gap-2", 3 => "gap-3",
      4 => "gap-4", 5 => "gap-5", 6 => "gap-6", 8 => "gap-8",
      10 => "gap-10", 12 => "gap-12", 16 => "gap-16"
    }.freeze

    COLS = {
      1 => "grid-cols-1", 2 => "grid-cols-2", 3 => "grid-cols-3",
      4 => "grid-cols-4", 5 => "grid-cols-5", 6 => "grid-cols-6",
      12 => "grid-cols-12"
    }.freeze

    ALIGN = {
      start: "items-start", center: "items-center", end: "items-end",
      stretch: "items-stretch", baseline: "items-baseline"
    }.freeze

    JUSTIFY = {
      start: "justify-start", center: "justify-center", end: "justify-end",
      between: "justify-between", around: "justify-around", evenly: "justify-evenly"
    }.freeze

    CONTAINER_SIZE = {
      sm: "max-w-3xl", md: "max-w-5xl", lg: "max-w-7xl",
      xl: "max-w-screen-2xl", full: ""
    }.freeze

    # Accessed via `sui.layout` on the builder.
    class Namespace
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::OutputSafetyHelper
      include ActionView::Context

      def initialize(view_context)
        @view_context = view_context
      end

      def stack(gap: nil, align: nil, **opts, &block)
        opts[:class] = Shadcnrb::TailwindMerge.call(
          "flex flex-col",
          gap && Shadcnrb::TailwindMerge.fetch_variant(GAP, gap, kind: :gap, component: :stack),
          align && Shadcnrb::TailwindMerge.fetch_variant(ALIGN, align, kind: :align,
            component: :stack),
          opts[:class]
        )
        content_tag(:div, **opts) { block ? @view_context.capture(&block) : "" }
      end

      def row(gap: nil, align: :center, justify: nil, wrap: true, **opts, &block)
        opts[:class] = Shadcnrb::TailwindMerge.call(
          "flex",
          wrap ? "flex-wrap" : "flex-nowrap",
          gap && Shadcnrb::TailwindMerge.fetch_variant(GAP, gap, kind: :gap, component: :row),
          align && Shadcnrb::TailwindMerge.fetch_variant(ALIGN, align, kind: :align,
            component: :row),
          justify && Shadcnrb::TailwindMerge.fetch_variant(JUSTIFY, justify, kind: :justify,
            component: :row),
          opts[:class]
        )
        content_tag(:div, **opts) { block ? @view_context.capture(&block) : "" }
      end

      def grid(cols: nil, gap: nil, **opts, &block)
        opts[:class] = Shadcnrb::TailwindMerge.call(
          "grid",
          cols && Shadcnrb::TailwindMerge.fetch_variant(COLS, cols, kind: :cols,
            component: :grid),
          gap && Shadcnrb::TailwindMerge.fetch_variant(GAP, gap, kind: :gap, component: :grid),
          opts[:class]
        )
        content_tag(:div, **opts) { block ? @view_context.capture(&block) : "" }
      end

      def container(size: :md, **opts, &block)
        opts[:class] = Shadcnrb::TailwindMerge.call(
          "mx-auto w-full px-4 sm:px-6 lg:px-8",
          Shadcnrb::TailwindMerge.fetch_variant(CONTAINER_SIZE, size, kind: :size,
            component: :container),
          opts[:class]
        )
        content_tag(:div, **opts) { block ? @view_context.capture(&block) : "" }
      end
    end

    def layout
      @_namespace ||= Namespace.new(@builder.view_context)
    end
  end
end
