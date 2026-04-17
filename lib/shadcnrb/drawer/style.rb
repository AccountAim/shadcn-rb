# frozen_string_literal: true

class Shadcnrb::Drawer::Style
  def backdrop
    "fixed inset-0 z-50 bg-black/50 pointer-events-none opacity-0 transition-opacity duration-300 " \
      "data-[state=open]:pointer-events-auto data-[state=open]:opacity-100 " \
      "data-[state=closed]:animate-out data-[state=closed]:fade-out-0 " \
      "data-[state=open]:animate-in data-[state=open]:fade-in-0"
  end

  def content_base = "fixed z-50 flex h-auto flex-col bg-background shadow-lg transition-transform duration-300 ease-in-out"

  def sides
    {
      right:  "inset-y-0 right-0 h-full w-3/4 max-w-sm border-l translate-x-full data-[state=open]:translate-x-0",
      left:   "inset-y-0 left-0 h-full w-3/4 max-w-sm border-r -translate-x-full data-[state=open]:translate-x-0",
      top:    "inset-x-0 top-0 h-auto max-h-[80vh] mb-24 rounded-b-lg border-b -translate-y-full data-[state=open]:translate-y-0",
      bottom: "inset-x-0 bottom-0 h-auto max-h-[80vh] mt-24 rounded-t-lg border-t translate-y-full data-[state=open]:translate-y-0"
    }
  end

  def close_btn_pos = "absolute top-4 right-4 opacity-70 hover:opacity-100 transition-opacity"

  def header      = "flex flex-col gap-0.5 p-4 md:gap-1.5 md:text-left"
  def footer      = "mt-auto flex flex-col gap-2 p-4"
  def title       = "font-semibold text-foreground"
  def description = "text-sm text-muted-foreground"
end
