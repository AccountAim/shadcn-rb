# frozen_string_literal: true

class Shadcnrb::Tooltip::Style
  # The root hugs the trigger — its rect is what the panel anchors to.
  def root = "inline-block"

  # Placement is inline-styled by the anchored controller. `overflow-visible`
  # undoes the UA's `[popover] { overflow: auto }` so the arrow can peek out.
  def content
    <<~CLASSES.squish
      fixed z-50 w-fit max-w-xs overflow-visible rounded-md bg-foreground
      px-3 py-1.5 text-xs text-balance text-background shadow-md
      hidden data-[state=open]:block
    CLASSES
  end

  # Rotated square peeking out of the panel edge nearest the trigger; the
  # controller places it, pointing at the trigger's centre.
  def arrow = "absolute size-2.5 rotate-45 rounded-[2px] bg-foreground"
end
