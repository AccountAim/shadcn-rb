# frozen_string_literal: true

module Shadcnrb
  module Breadcrumb::Component
    def breadcrumb(*args, **kwargs, &block)
      (@breadcrumb ||= Shadcnrb::Breadcrumb.new(self)).breadcrumb(*args, **kwargs, &block)
    end

    def breadcrumb_proxy
      (@breadcrumb ||= Shadcnrb::Breadcrumb.new(self)).proxy
    end
  end
end
