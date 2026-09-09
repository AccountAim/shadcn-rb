# frozen_string_literal: true

module Shadcnrb
  module ThemeSwitcher::Component
    def theme_switcher(*args, **kwargs, &block)
      (@theme_switcher ||= Shadcnrb::ThemeSwitcher.new(self)).theme_switcher(*args, **kwargs, &block)
    end

    def theme_class(**kwargs)
      (@theme_switcher ||= Shadcnrb::ThemeSwitcher.new(self)).theme_class(**kwargs)
    end
  end
end
