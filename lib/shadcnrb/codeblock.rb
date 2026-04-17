# frozen_string_literal: true

require "rouge"

module Shadcnrb
  class Codeblock < Component
    FORMATTER = ::Rouge::Formatters::HTML.new
    THEME_CSS = [
      ::Rouge::Themes::Github.mode(:light).render(scope: ".shadcnrb-code"),
      ::Rouge::Themes::Github.mode(:dark).render(scope: ".dark .shadcnrb-code")
    ].join("\n").freeze

    def codeblock(code = nil, syntax: :ruby, **opts, &block)
      source = block ? capture(&block) : code.to_s
      source = source.to_s.strip
      lexer  = ::Rouge::Lexer.find(syntax.to_sym) || ::Rouge::Lexers::PlainText.new
      html   = FORMATTER.format(lexer.lex(source))
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.base, opts[:class])
      content_tag(:div, **opts) do
        content_tag(:pre, class: self.class.style.pre) { html.html_safe }
      end
    end

    def codeblock_theme_styles
      content_tag(:style, THEME_CSS.html_safe)
    end
  end
end
