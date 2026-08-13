# frozen_string_literal: true

module Shadcnrb
  module Skeleton::Component
    def skeleton(*args, **kwargs, &block)
      (@_skeleton ||= Shadcnrb::Skeleton.new(self)).skeleton(*args, **kwargs, &block)
    end
  end
end
