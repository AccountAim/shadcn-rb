# frozen_string_literal: true

module Shadcnrb
  module Codeblock::Component
    def codeblock(*args, **kwargs, &block)
      (@codeblock ||= Shadcnrb::Codeblock.new(self)).codeblock(*args, **kwargs, &block)
    end

    def codeblock_theme_styles
      (@codeblock ||= Shadcnrb::Codeblock.new(self)).codeblock_theme_styles
    end
  end
end
