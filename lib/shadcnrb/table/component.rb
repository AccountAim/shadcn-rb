# frozen_string_literal: true

module Shadcnrb
  module Table::Component
    def table(*args, **kwargs, &block)
      (@_table ||= Shadcnrb::Table.new(self)).table(*args, **kwargs, &block)
    end

    def table_proxy
      (@_table ||= Shadcnrb::Table.new(self)).proxy
    end
  end
end
