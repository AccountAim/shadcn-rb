# frozen_string_literal: true

module Shadcnrb
  module Card::Component
    def card(*args, **kwargs, &block)
      (@_card ||= Shadcnrb::Card.new(self)).card(*args, **kwargs, &block)
    end

    def card_proxy
      (@_card ||= Shadcnrb::Card.new(self)).proxy
    end
  end
end
