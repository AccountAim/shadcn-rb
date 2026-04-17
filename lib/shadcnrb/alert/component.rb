# frozen_string_literal: true

module Shadcnrb
  module Alert::Component
    def alert(*args, **kwargs, &block)
      (@_alert ||= Shadcnrb::Alert.new(self)).alert(*args, **kwargs, &block)
    end

    def alert_title(*args, **kwargs, &block)
      (@_alert ||= Shadcnrb::Alert.new(self)).title(*args, **kwargs, &block)
    end

    def alert_description(*args, **kwargs, &block)
      (@_alert ||= Shadcnrb::Alert.new(self)).description(*args, **kwargs, &block)
    end
  end
end
