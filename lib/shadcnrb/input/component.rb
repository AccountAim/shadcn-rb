# frozen_string_literal: true

module Shadcnrb
  module Input::Component
    def input(*args, **kwargs, &block)
      (@_input ||= Shadcnrb::Input.new(self)).input(*args, **kwargs, &block)
    end
  end
end
