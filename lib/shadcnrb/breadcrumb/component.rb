# frozen_string_literal: true

module Shadcnrb
  module Breadcrumb::Component
    def breadcrumb(*args, **kwargs, &block)
      (@_breadcrumb ||= Shadcnrb::Breadcrumb.new(self)).breadcrumb(*args, **kwargs, &block)
    end

    def breadcrumb_proxy
      (@_breadcrumb ||= Shadcnrb::Breadcrumb.new(self)).proxy
    end
  end
end
