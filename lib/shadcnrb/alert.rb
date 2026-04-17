# frozen_string_literal: true

module Shadcnrb
  class Alert < Component
    def alert(name = nil, variant: :default, **opts, &block)
      opts[:class] = classes_from_style(self.class.style, variant:, custom: opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "alert", variant: variant.to_s)
      opts[:role] = "alert"
      content_tag(:div, **opts) { block ? capture(&block) : name.to_s }
    end

    def title(name = nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.title, opts[:class])
      opts[:"data-slot"] = "alert-title"
      content_tag(:div, **opts) { block ? capture(&block) : name.to_s }
    end

    def description(name = nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.description, opts[:class])
      opts[:"data-slot"] = "alert-description"
      content_tag(:div, **opts) { block ? capture(&block) : name.to_s }
    end
  end
end
