# frozen_string_literal: true

class Shadcnrb::Empty::Style
  def root        = "flex min-w-0 flex-1 flex-col items-center justify-center gap-6 rounded-lg border border-dashed p-6 text-center text-balance md:p-12"
  def header      = "flex max-w-sm flex-col items-center gap-2 text-center"
  def media_base  = "mb-2 flex shrink-0 items-center justify-center [&_svg]:pointer-events-none [&_svg]:shrink-0"

  def media_variants
    {
      default: "bg-transparent",
      icon:    "flex size-10 shrink-0 items-center justify-center rounded-lg bg-muted text-foreground [&_svg:not([class*='size-'])]:size-6"
    }
  end

  def title       = "text-lg font-medium tracking-tight"
  def description = "text-sm/relaxed text-muted-foreground [&>a]:underline [&>a]:underline-offset-4 [&>a:hover]:text-primary"
  def content     = "flex w-full max-w-sm min-w-0 flex-col items-center gap-4 text-sm text-balance"
end
