# frozen_string_literal: true

# Thin delegator — all logic lives on `Shadcnrb::Button`.

module Shadcnrb
  module Button::Component
    def button(*args, **kwargs, &block)
      (@_button ||= Shadcnrb::Button.new(self)).button(*args, **kwargs, &block)
    end

    def button_to(*args, **kwargs, &block)
      (@_button ||= Shadcnrb::Button.new(self)).button_to(*args, **kwargs, &block)
    end
  end
end
