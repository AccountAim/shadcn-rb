# frozen_string_literal: true

module Shadcnrb
  class Badge < Component
    def badge(name = nil, variant: :default, **opts, &block)
      opts[:class] = classes_from_style(self.class.style, variant:, custom: opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "badge", variant: variant.to_s)
      content_tag(:span, **opts) do
        block ? capture(&block) : name.to_s
      end
    end
  end
end
