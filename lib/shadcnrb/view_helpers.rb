# frozen_string_literal: true

module Shadcnrb
  # Exposes `sui` on every ActionView instance. Mixed in via the
  # `on_load(:action_view)` block in `config/initializers/shadcnrb.rb`,
  # so no `ApplicationHelper` edit is needed.
  #
  # Builder allocation is a thin wrapper around `self` (the view context);
  # skip the ivar memoisation dance — the cost is noise, not allocations.
  module ViewHelpers
    def sui
      Shadcnrb::Builder.new(self)
    end
  end
end
