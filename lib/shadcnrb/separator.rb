# frozen_string_literal: true

module Shadcnrb
  class Separator < Component
    def separator(orientation: :horizontal, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.base, opts[:class])
      opts[:role] = "separator"
      opts[:"aria-orientation"] = orientation.to_s
      opts[:"data-orientation"] = orientation.to_s
      content_tag(:div, "", opts)
    end
  end
end
