# frozen_string_literal: true

module Shadcnrb
  module ThemeSwitcher::Component
    def theme_switcher(*args, **kwargs, &block)
      (@_theme_switcher ||= Shadcnrb::ThemeSwitcher.new(self)).theme_switcher(*args, **kwargs, &block)
    end

    def theme_switcher_init
      (@_theme_switcher ||= Shadcnrb::ThemeSwitcher.new(self)).theme_switcher_init
    end
  end
end
