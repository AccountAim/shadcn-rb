# frozen_string_literal: true

class Shadcnrb::Toast::Style
  def trigger_wrapper = "inline-block"

  def base
    "pointer-events-auto relative flex w-full items-center justify-between space-x-2 " \
      "overflow-hidden rounded-md p-4 shadow-lg transition-all"
  end

  def variants
    {
      default:     "bg-background text-foreground border",
      destructive: "bg-destructive text-destructive-foreground border-destructive"
    }
  end
end
