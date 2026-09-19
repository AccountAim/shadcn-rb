# frozen_string_literal: true

class Shadcnrb::Drawer::Style
  # `m-0 w-auto h-auto border-0 p-0` on the backdrop, `m-0 p-0 text-foreground`
  # plus the free side and the stretched axis set to `auto` on the panel undo
  # the UA's `[popover]` box (`inset: 0; margin: auto; fit-content sizing;
  # border; padding; CanvasText`).
  def backdrop
    <<~CLASSES.squish
      fixed inset-0 z-50 m-0 w-auto h-auto border-0 p-0
      bg-black/50 pointer-events-none opacity-0 transition-opacity duration-300
      data-[state=open]:pointer-events-auto data-[state=open]:opacity-100
      data-[state=closed]:animate-out data-[state=closed]:fade-out-0
      data-[state=open]:animate-in data-[state=open]:fade-in-0
    CLASSES
  end

  def content_base = "fixed z-50 m-0 p-0 flex h-auto flex-col bg-background text-foreground shadow-lg transition-transform duration-300 ease-in-out"

  def sides
    {
      right:  "inset-y-0 right-0 left-auto h-full w-3/4 max-w-sm border-l translate-x-full data-[state=open]:translate-x-0",
      left:   "inset-y-0 left-0 right-auto h-full w-3/4 max-w-sm border-r -translate-x-full data-[state=open]:translate-x-0",
      top:    "inset-x-0 top-0 bottom-auto w-auto h-auto max-h-[80vh] mb-24 rounded-b-lg border-b -translate-y-full data-[state=open]:translate-y-0",
      bottom: "inset-x-0 bottom-0 top-auto w-auto h-auto max-h-[80vh] mt-24 rounded-t-lg border-t translate-y-full data-[state=open]:translate-y-0"
    }
  end

  def close_delay = 300

  def close_btn_pos = "absolute top-4 right-4 opacity-70 hover:opacity-100 transition-opacity"

  def header      = "flex flex-col gap-0.5 p-4 md:gap-1.5 md:text-left"
  def footer      = "mt-auto flex flex-col gap-2 p-4"
  def title       = "font-semibold text-foreground"
  def description = "text-sm text-muted-foreground"
end
