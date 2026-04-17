# frozen_string_literal: true

module Shadcnrb
  module Label::Component
    def label(*args, **kwargs, &block)
      (@_label ||= Shadcnrb::Label.new(self)).label(*args, **kwargs, &block)
    end
  end
end
