# frozen_string_literal: true

module Shadcnrb
  module Separator::Component
    def separator(*args, **kwargs, &block)
      (@_separator ||= Shadcnrb::Separator.new(self)).separator(*args, **kwargs, &block)
    end
  end
end
