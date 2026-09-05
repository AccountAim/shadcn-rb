# frozen_string_literal: true

module Shadcnrb
  module Collapsible::Component
    def collapsible(*args, **kwargs, &block)
      (@collapsible ||= Shadcnrb::Collapsible.new(self)).collapsible(*args, **kwargs, &block)
    end

    def collapsible_proxy
      (@collapsible ||= Shadcnrb::Collapsible.new(self)).proxy
    end
  end
end
