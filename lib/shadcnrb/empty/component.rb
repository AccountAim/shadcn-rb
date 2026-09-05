# frozen_string_literal: true

module Shadcnrb
  module Empty::Component
    def empty(*args, **kwargs, &block)
      (@empty ||= Shadcnrb::Empty.new(self)).empty(*args, **kwargs, &block)
    end

    def empty_proxy
      (@empty ||= Shadcnrb::Empty.new(self)).proxy
    end
  end
end
