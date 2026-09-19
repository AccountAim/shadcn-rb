# frozen_string_literal: true

module Shadcnrb
  module Drawer::Component
    def drawer(*args, **kwargs, &block)
      (@drawer ||= Shadcnrb::Drawer.new(self)).drawer(*args, **kwargs, &block)
    end

    def drawer_proxy
      (@drawer ||= Shadcnrb::Drawer.new(self)).proxy
    end
  end
end
