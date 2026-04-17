# frozen_string_literal: true

# shadcn divergence: upstream has no dedicated Link component — links use
# `<Button variant="link">`. We keep a dedicated `sui.link_to` (Rails-idiomatic)
# and mirror Button's layout + SVG handling on the base so icon + label
# composition is identical across the two helpers.

class Shadcnrb::Link::Style
  def base
    "inline-flex items-center gap-2 cursor-pointer transition-colors underline-offset-4 " \
      "focus-visible:outline-none focus-visible:underline " \
      "disabled:pointer-events-none disabled:opacity-50 " \
      "aria-disabled:pointer-events-none aria-disabled:opacity-50 " \
      "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
  end

  def variants
    {
      link:       "text-primary hover:underline",
      underline:  "text-primary underline hover:no-underline",
      muted:      "text-muted-foreground hover:text-foreground hover:underline",
      foreground: "text-foreground hover:underline"
    }
  end

  def sizes
    {
      sm:      "text-xs",
      default: "text-sm",
      lg:      "text-base"
    }
  end
end
