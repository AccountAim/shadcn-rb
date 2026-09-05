# frozen_string_literal: true

class Shadcnrb::Toast::Style
  def trigger_wrapper = "inline-block"

  # Body-level container every toast lands in; `positions` picks its corner.
  def container = "pointer-events-none fixed z-[100] flex w-full max-w-sm flex-col gap-2"

  def positions
    {
      "top-left": "left-4 top-4",
      "top-center": "left-1/2 top-4 -translate-x-1/2",
      "top-right": "right-4 top-4",
      "bottom-left": "bottom-4 left-4",
      "bottom-center": "bottom-4 left-1/2 -translate-x-1/2",
      "bottom-right": "bottom-4 right-4"
    }
  end

  def base
    <<~CLASSES.squish
      pointer-events-auto relative flex w-full items-center gap-3 overflow-hidden
      rounded-lg border p-4 shadow-lg transition-all
    CLASSES
  end

  def variants
    {
      default:     "bg-background text-foreground",
      destructive: "bg-destructive text-destructive-foreground border-destructive"
    }
  end

  # Leading icon per variant; an app style can retint or drop them.
  def icons
    {
      default:     { name: :"circle-check", class: "size-5 shrink-0" },
      destructive: { name: :"circle-alert", class: "size-5 shrink-0" }
    }
  end

  def title       = "text-sm font-medium"
  def description = "text-sm opacity-80"
  def close       = "shrink-0 rounded-sm opacity-60 transition-opacity hover:opacity-100"
end
