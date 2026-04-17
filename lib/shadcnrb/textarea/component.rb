# frozen_string_literal: true

module Shadcnrb
  module Textarea::Component
    def textarea(*args, **kwargs, &block)
      (@_textarea ||= Shadcnrb::Textarea.new(self)).textarea(*args, **kwargs, &block)
    end
  end
end
