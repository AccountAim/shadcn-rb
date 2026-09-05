# frozen_string_literal: true

module Shadcnrb
  module Layout::Component
    def layout
      (@layout ||= Shadcnrb::Layout.new(self)).layout
    end
  end
end
