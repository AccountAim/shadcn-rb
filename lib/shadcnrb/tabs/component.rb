# frozen_string_literal: true

module Shadcnrb
  module Tabs::Component
    def tabs(*args, **kwargs, &block)
      (@_tabs ||= Shadcnrb::Tabs.new(self)).tabs(*args, **kwargs, &block)
    end
  end
end
