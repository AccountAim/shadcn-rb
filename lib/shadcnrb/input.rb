# frozen_string_literal: true

module Shadcnrb
  class Input < Component
    def input(type: "text", **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.base, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "input")
      tag.input(type:, **opts)
    end
  end
end
