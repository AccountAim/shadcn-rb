# frozen_string_literal: true

module Shadcnrb
  module Select::Component
    def select(*args, **kwargs, &block)
      (@select ||= Shadcnrb::Select.new(self)).select(*args, **kwargs, &block)
    end
  end
end
