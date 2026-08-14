# frozen_string_literal: true

module Shadcnrb
  module DropdownMenu::Component
    def dropdown_menu(*args, **kwargs, &block)
      (@_dropdown_menu ||= Shadcnrb::DropdownMenu.new(self)).dropdown_menu(*args, **kwargs, &block)
    end

    def dropdown_menu_proxy
      (@_dropdown_menu ||= Shadcnrb::DropdownMenu.new(self)).proxy
    end
  end
end
