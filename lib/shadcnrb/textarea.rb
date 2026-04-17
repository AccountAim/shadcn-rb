# frozen_string_literal: true

module Shadcnrb
  class Textarea < Component
    def textarea(name_or_content = nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.base, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "textarea")
      content = block ? capture(&block) : name_or_content.to_s
      content_tag(:textarea, content, **opts)
    end
  end
end
