# frozen_string_literal: true

module Shadcnrb
  module Switch::Component
    def switch(*args, **kwargs, &block)
      (@switch ||= Shadcnrb::Switch.new(self)).switch(*args, **kwargs, &block)
    end
  end
end
