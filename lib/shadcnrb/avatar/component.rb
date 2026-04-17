# frozen_string_literal: true

module Shadcnrb
  module Avatar::Component
    def avatar(*args, **kwargs, &block)
      (@_avatar ||= Shadcnrb::Avatar.new(self)).avatar(*args, **kwargs, &block)
    end

    def avatar_proxy
      (@_avatar ||= Shadcnrb::Avatar.new(self)).proxy
    end
  end
end
