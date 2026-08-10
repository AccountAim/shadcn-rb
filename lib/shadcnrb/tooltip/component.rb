# frozen_string_literal: true

module Shadcnrb
  module Tooltip::Component
    def tooltip(*args, **kwargs, &block)
      (@_tooltip ||= Shadcnrb::Tooltip.new(self)).tooltip(*args, **kwargs, &block)
    end
  end
end
