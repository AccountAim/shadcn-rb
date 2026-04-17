# frozen_string_literal: true

module Shadcnrb
  module Layout::Component
    def layout
      (@_layout ||= Shadcnrb::Layout.new(self)).layout
    end
  end
end
