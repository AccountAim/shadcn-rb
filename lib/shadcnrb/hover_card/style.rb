# frozen_string_literal: true

class Shadcnrb::HoverCard::Style
  # The root hugs the trigger — its rect is what the panel anchors to.
  def root = "inline-block"

  # Placement is inline-styled by the anchored controller. `overflow-visible`
  # undoes the UA's `[popover] { overflow: auto }`.
  def content
    <<~CLASSES.squish
      fixed z-50 w-64 overflow-visible rounded-md border bg-popover p-4
      text-popover-foreground shadow-md outline-hidden
      hidden data-[state=open]:block
    CLASSES
  end
end
