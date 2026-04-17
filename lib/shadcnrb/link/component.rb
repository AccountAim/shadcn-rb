# frozen_string_literal: true

# Thin delegator — all logic lives on `Shadcnrb::Link`.

module Shadcnrb
  module Link::Component
    def link_to(*args, **kwargs, &block)
      (@_link ||= Shadcnrb::Link.new(self)).link_to(*args, **kwargs, &block)
    end
  end
end
