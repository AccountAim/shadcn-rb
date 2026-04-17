# frozen_string_literal: true

class Shadcnrb::Typography::Style
  def h1    = "text-4xl font-bold tracking-tight"
  def h2    = "text-2xl font-semibold tracking-tight"
  def h3    = "text-lg font-semibold"
  def h4    = "text-base font-semibold"
  def p     = "text-sm leading-relaxed"
  def lead  = "text-lg text-muted-foreground"
  def muted = "text-sm text-muted-foreground"
  def code  = "text-xs bg-muted px-1.5 py-0.5 rounded font-mono"

  # Size scale shared across headings. Pass `size:` on any `h1`..`h4` to
  # override the tag's natural size without changing the semantic element.
  def heading_sizes
    {
      xs:      "text-sm",
      sm:      "text-base",
      default: nil,
      md:      "text-lg",
      lg:      "text-xl",
      xl:      "text-2xl",
      "2xl":   "text-4xl"
    }
  end
end
