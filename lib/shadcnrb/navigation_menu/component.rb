# frozen_string_literal: true

module Shadcnrb
  module NavigationMenu::Component
    def navigation_menu(*args, **kwargs, &block)
      (@_navigation_menu ||= Shadcnrb::NavigationMenu.new(self)).navigation_menu(*args, **kwargs, &block)
    end

    def navigation_menu_proxy
      (@_navigation_menu ||= Shadcnrb::NavigationMenu.new(self)).proxy
    end
  end
end
