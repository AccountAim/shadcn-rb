# frozen_string_literal: true

module Shadcnrb
  module Badge::Component
    def badge(*args, **kwargs, &block)
      (@badge ||= Shadcnrb::Badge.new(self)).badge(*args, **kwargs, &block)
    end
  end
end
