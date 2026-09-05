# frozen_string_literal: true

module Shadcnrb
  module FormField::Component
    def form_field(*args, **kwargs, &block)
      (@form_field ||= Shadcnrb::FormField.new(self)).form_field(*args, **kwargs, &block)
    end
  end
end
