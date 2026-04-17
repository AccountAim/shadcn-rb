# frozen_string_literal: true

module Shadcnrb
  module Drawer::Component
    def drawer(*args, **kwargs, &block)
      (@_drawer ||= Shadcnrb::Drawer.new(self)).drawer(*args, **kwargs, &block)
    end
  end
end
