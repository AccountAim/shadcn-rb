# frozen_string_literal: true

module Shadcnrb
  class Select < Component
    def select(size: :default, **opts, &block)
      style = self.class.style
      opts[:class] = Shadcnrb::TailwindMerge.call(style.base, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "native-select", size: size.to_s)
      content_tag(:div, class: style.wrapper, data: { slot: "native-select-wrapper" }) do
        safe_join([
          content_tag(:select, **opts, &block),
          icon(:"chevron-down", class: style.chevron)
        ])
      end
    end
  end
end
