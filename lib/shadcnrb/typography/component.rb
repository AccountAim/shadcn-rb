# frozen_string_literal: true

module Shadcnrb
  module Typography::Component
    def h1(*args, **kwargs, &block)
      (@_typography ||= Shadcnrb::Typography.new(self)).h1(*args, **kwargs, &block)
    end

    def h2(*args, **kwargs, &block)
      (@_typography ||= Shadcnrb::Typography.new(self)).h2(*args, **kwargs, &block)
    end

    def h3(*args, **kwargs, &block)
      (@_typography ||= Shadcnrb::Typography.new(self)).h3(*args, **kwargs, &block)
    end

    def h4(*args, **kwargs, &block)
      (@_typography ||= Shadcnrb::Typography.new(self)).h4(*args, **kwargs, &block)
    end

    def p(*args, **kwargs, &block)
      (@_typography ||= Shadcnrb::Typography.new(self)).p(*args, **kwargs, &block)
    end

    def lead(*args, **kwargs, &block)
      (@_typography ||= Shadcnrb::Typography.new(self)).lead(*args, **kwargs, &block)
    end

    def muted(*args, **kwargs, &block)
      (@_typography ||= Shadcnrb::Typography.new(self)).muted(*args, **kwargs, &block)
    end

    def code(*args, **kwargs, &block)
      (@_typography ||= Shadcnrb::Typography.new(self)).code(*args, **kwargs, &block)
    end
  end
end
