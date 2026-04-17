# frozen_string_literal: true

module Shadcnrb
  class Label < Component
    def label(name = nil, for_id: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.base, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "label")
      body = block ? capture(&block) : name.to_s
      label_tag(for_id, body, opts)
    end
  end
end
