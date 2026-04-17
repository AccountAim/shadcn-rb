# frozen_string_literal: true

class Shadcnrb::Select::Style
  def wrapper = "group/native-select relative w-full has-[select:disabled]:opacity-50"
  def base    = "h-9 w-full min-w-0 appearance-none rounded-md border border-input bg-transparent px-3 py-2 pr-9 text-sm shadow-xs transition-[color,box-shadow] outline-none cursor-pointer placeholder:text-muted-foreground disabled:pointer-events-none disabled:cursor-not-allowed focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 data-[size=sm]:h-8 data-[size=sm]:py-1"
  def chevron = "pointer-events-none absolute top-1/2 right-3.5 size-4 -translate-y-1/2 text-muted-foreground opacity-50 select-none"
end
