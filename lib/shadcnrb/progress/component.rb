# frozen_string_literal: true

module Shadcnrb
  module Progress::Component
    def progress(*args, **kwargs, &block)
      (@_progress ||= Shadcnrb::Progress.new(self)).progress(*args, **kwargs, &block)
    end
  end
end
