# frozen_string_literal: true

module Shadcnrb
  module DataGrid::Component
    def data_grid(*args, **kwargs, &block)
      (@data_grid ||= Shadcnrb::DataGrid.new(self)).data_grid(*args, **kwargs, &block)
    end

    # Rows rendered outside a `sui.data_grid` block, e.g. a Turbo stream
    # appending to the body; the controller stamps their cells from the
    # header, so it takes no arguments unless the grid was built from `columns:`.
    def data_grid_proxy(**kwargs)
      (@data_grid ||= Shadcnrb::DataGrid.new(self)).proxy(**kwargs)
    end
  end
end
