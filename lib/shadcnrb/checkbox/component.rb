# frozen_string_literal: true

module Shadcnrb
  module Checkbox::Component
    def checkbox(*args, **kwargs, &block)
      (@_checkbox ||= Shadcnrb::Checkbox.new(self)).checkbox(*args, **kwargs, &block)
    end
  end
end
