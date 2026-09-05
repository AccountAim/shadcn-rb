# frozen_string_literal: true

module Shadcnrb
  module Tabs::Component
    def tabs(*args, **kwargs, &block)
      (@tabs ||= Shadcnrb::Tabs.new(self)).tabs(*args, **kwargs, &block)
    end

    def tabs_strip(*args, **kwargs)
      (@tabs ||= Shadcnrb::Tabs.new(self)).tabs_strip(*args, **kwargs)
    end
  end
end
