# frozen_string_literal: true

module Shadcnrb
  module Sidebar::Component
    def sidebar_wrapper(*args, **kwargs, &block)
      (@sidebar ||= Shadcnrb::Sidebar.new(self)).sidebar_wrapper(*args, **kwargs, &block)
    end

    def sidebar_proxy
      (@sidebar ||= Shadcnrb::Sidebar.new(self)).proxy
    end
  end
end
