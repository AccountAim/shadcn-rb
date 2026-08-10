# frozen_string_literal: true

module Shadcnrb
  module HoverCard::Component
    def hover_card(*args, **kwargs, &block)
      (@_hover_card ||= Shadcnrb::HoverCard.new(self)).hover_card(*args, **kwargs, &block)
    end
  end
end
