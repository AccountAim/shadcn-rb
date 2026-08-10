# frozen_string_literal: true

class Shadcnrb::Tooltip::Style
  def root = "relative inline-block"

  # `hidden` (not `opacity-0`) when closed so the panel leaves layout —
  # otherwise a tooltip near the viewport edge causes horizontal overflow on
  # the whole page.
  #
  # `w-max` (not upstream's `w-fit`): shrink-to-fit on an absolutely
  # positioned box is capped by the containing block, so `w-fit` wraps the
  # label to the trigger's width. `max-w-xs` still bounds long text.
  def content
    "absolute z-50 w-max max-w-xs rounded-md bg-foreground px-3 py-1.5 " \
      "text-xs text-balance text-background shadow-md " \
      "hidden data-[state=open]:block"
  end

  # 4px gap (`mb-1` / `mt-1` / …) stands in for upstream's `sideOffset`.
  def sides
    {
      top:    "bottom-full left-1/2 -translate-x-1/2 mb-1",
      bottom: "top-full left-1/2 -translate-x-1/2 mt-1",
      left:   "right-full top-1/2 -translate-y-1/2 mr-1",
      right:  "left-full top-1/2 -translate-y-1/2 ml-1"
    }
  end

  # Applied on top of `sides`, so `:center` is the no-op the side table
  # already encodes.
  def align_x
    {
      center: "",
      start:  "left-0 translate-x-0",
      end:    "left-auto right-0 translate-x-0"
    }
  end

  def align_y
    {
      center: "",
      start:  "top-0 translate-y-0",
      end:    "top-auto bottom-0 translate-y-0"
    }
  end

  # Rotated square peeking out of the panel edge nearest the trigger. Stays
  # centred regardless of `align:` — upstream nudges it with `arrowPadding`.
  def arrow = "absolute z-50 size-2.5 rotate-45 rounded-[2px] bg-foreground"

  def arrow_sides
    {
      top:    "bottom-0 left-1/2 -translate-x-1/2 translate-y-1/2",
      bottom: "top-0 left-1/2 -translate-x-1/2 -translate-y-1/2",
      left:   "right-0 top-1/2 -translate-y-1/2 translate-x-1/2",
      right:  "left-0 top-1/2 -translate-y-1/2 -translate-x-1/2"
    }
  end
end
