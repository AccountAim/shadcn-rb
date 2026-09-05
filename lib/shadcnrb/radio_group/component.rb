# frozen_string_literal: true

module Shadcnrb
  module RadioGroup::Component
    def radio_group(*args, **kwargs, &block)
      (@radio_group ||= Shadcnrb::RadioGroup.new(self)).radio_group(*args, **kwargs, &block)
    end

    def radio_group_proxy
      (@radio_group ||= Shadcnrb::RadioGroup.new(self)).proxy
    end
  end
end
