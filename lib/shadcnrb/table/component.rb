# frozen_string_literal: true

module Shadcnrb
  module Table::Component
    def table(*args, **kwargs, &block)
      (@table ||= Shadcnrb::Table.new(self)).table(*args, **kwargs, &block)
    end

    def table_proxy
      (@table ||= Shadcnrb::Table.new(self)).proxy
    end
  end
end
