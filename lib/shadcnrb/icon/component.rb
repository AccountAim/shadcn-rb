# frozen_string_literal: true

module Shadcnrb
  module Icon::Component
    def icon(*args, **kwargs, &block)
      (@_icon ||= Shadcnrb::Icon.new(self)).icon(*args, **kwargs, &block)
    end
  end
end
