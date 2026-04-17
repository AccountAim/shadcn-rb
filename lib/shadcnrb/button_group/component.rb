# frozen_string_literal: true

module Shadcnrb
  module ButtonGroup::Component
    def button_group(*args, **kwargs, &block)
      (@_button_group ||= Shadcnrb::ButtonGroup.new(self)).button_group(*args, **kwargs, &block)
    end

    def button_group_proxy
      (@_button_group ||= Shadcnrb::ButtonGroup.new(self)).proxy
    end
  end
end
