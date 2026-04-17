# frozen_string_literal: true

class Shadcnrb::Tabs::Style
  def root = "group/tabs flex flex-col gap-2 data-[orientation=vertical]:flex-row"

  def list_base
    "inline-flex items-center justify-center text-muted-foreground"
  end

  def list_variants
    {
      default: "w-fit rounded-lg bg-muted p-[3px] h-9",
      line:    "w-full border-b bg-transparent p-0 rounded-none"
    }
  end

  def trigger_base
    "relative inline-flex items-center justify-center gap-1.5 px-2 py-1 " \
      "text-sm font-medium whitespace-nowrap cursor-pointer transition-all " \
      "focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 outline-hidden " \
      "disabled:pointer-events-none disabled:opacity-50 " \
      "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
  end

  def trigger_variants
    {
      default: "h-[calc(100%-1px)] flex-1 rounded-md border border-transparent text-foreground/60 hover:text-foreground " \
                 "data-[state=active]:bg-background data-[state=active]:text-foreground data-[state=active]:shadow-sm",
      line:    "h-9 border-b-2 border-transparent text-foreground/60 hover:text-foreground rounded-none " \
                 "data-[state=active]:border-foreground data-[state=active]:text-foreground"
    }
  end

  def content = "flex-1 outline-none"
end
