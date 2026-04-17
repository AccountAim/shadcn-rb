# frozen_string_literal: true

module Shadcnrb
  module Toast::Component
    def toast(*args, **kwargs, &block)
      (@_toast ||= Shadcnrb::Toast.new(self)).toast(*args, **kwargs, &block)
    end

    def toast_trigger(*args, **kwargs, &block)
      (@_toast ||= Shadcnrb::Toast.new(self)).toast_trigger(*args, **kwargs, &block)
    end

    def flash_toasts
      (@_toast ||= Shadcnrb::Toast.new(self)).flash_toasts
    end

    def toast_stream(*args, **kwargs)
      (@_toast ||= Shadcnrb::Toast.new(self)).toast_stream(*args, **kwargs)
    end
  end
end
