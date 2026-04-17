# frozen_string_literal: true

class Shadcnrb::Dialog::Style
  def backdrop
    "fixed inset-0 z-50 bg-black/50 pointer-events-none opacity-0 transition-opacity duration-200 " \
      "data-[state=open]:pointer-events-auto data-[state=open]:opacity-100 " \
      "data-[state=closed]:animate-out data-[state=closed]:fade-out-0 " \
      "data-[state=open]:animate-in data-[state=open]:fade-in-0"
  end

  def content
    "fixed top-[50%] left-[50%] z-50 grid w-full max-w-[calc(100%-2rem)] " \
      "translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg border bg-background p-6 shadow-lg " \
      "duration-200 outline-none " \
      "pointer-events-none opacity-0 scale-95 transition-all " \
      "data-[state=open]:pointer-events-auto data-[state=open]:opacity-100 data-[state=open]:scale-100 " \
      "data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 " \
      "data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 " \
      "sm:max-w-lg"
  end

  def close_btn_pos = "absolute top-4 right-4 opacity-70 hover:opacity-100 transition-opacity data-[state=open]:bg-accent data-[state=open]:text-muted-foreground [&_svg]:pointer-events-none"

  def header      = "flex flex-col gap-2 text-center sm:text-left"
  def footer      = "flex flex-col-reverse gap-2 sm:flex-row sm:justify-end"
  def title       = "text-lg leading-none font-semibold"
  def description = "text-sm text-muted-foreground"
end
