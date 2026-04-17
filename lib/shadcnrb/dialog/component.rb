# frozen_string_literal: true

# Thin delegator included into the host `Shadcnrb::Builder` by the generator.
# All component logic lives on `Shadcnrb::Dialog` (a class); the Builder just
# caches one instance per view render.

module Shadcnrb
  module Dialog::Component
    def dialog(*args, **kwargs, &block)
      (@_dialog ||= Shadcnrb::Dialog.new(self)).dialog(*args, **kwargs, &block)
    end

    def dialog_proxy
      (@_dialog ||= Shadcnrb::Dialog.new(self)).proxy
    end
  end
end
