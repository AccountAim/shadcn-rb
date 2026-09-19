# frozen_string_literal: true

module Shadcnrb
  class Select < Component
    # `class:` lands on the wrapper, so a width bounds the select and its
    # chevron together.
    def select(size: :default, **opts, &block)
      style = self.class.style
      wrapper_class = Shadcnrb::TailwindMerge.call(style.wrapper, opts.delete(:class))
      opts[:class] = style.base
      opts[:data] = (opts[:data] || {}).merge(slot: "native-select", size: size.to_s)
      content_tag(:div, class: wrapper_class, data: { slot: "native-select-wrapper" }) do
        safe_join([
          content_tag(:select, **opts, &block),
          icon(:"chevron-down", class: style.chevron)
        ])
      end
    end
  end
end
