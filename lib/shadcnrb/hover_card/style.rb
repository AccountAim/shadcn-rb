# frozen_string_literal: true

class Shadcnrb::HoverCard::Style
  def root = "relative inline-block"

  # `hidden` (not `opacity-0`) when closed so the panel leaves layout —
  # otherwise a card near the viewport edge causes horizontal overflow on the
  # whole page.
  def content
    "absolute z-50 w-64 rounded-md border bg-popover p-4 " \
      "text-popover-foreground shadow-md outline-hidden " \
      "hidden data-[state=open]:block"
  end

  # 4px gap (`mt-1` / `mb-1` / …) stands in for upstream's `sideOffset`.
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
end
