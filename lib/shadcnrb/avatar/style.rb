# frozen_string_literal: true

class Shadcnrb::Avatar::Style
  def root     = "group/avatar relative flex size-8 shrink-0 overflow-hidden rounded-full select-none data-[size=lg]:size-10 data-[size=sm]:size-6"
  def image    = "aspect-square size-full"
  def fallback = "flex size-full items-center justify-center rounded-full bg-muted text-sm text-muted-foreground group-data-[size=sm]/avatar:text-xs"
end
