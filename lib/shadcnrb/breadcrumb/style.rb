# frozen_string_literal: true

class Shadcnrb::Breadcrumb::Style
  def nav       = ""
  def list      = "flex flex-wrap items-center gap-1.5 text-sm break-words text-muted-foreground sm:gap-2.5"
  def item      = "inline-flex items-center gap-1.5"
  def link      = "transition-colors hover:text-foreground"
  def page      = "font-normal text-foreground"
  def separator = "[&>svg]:size-3.5"
  def ellipsis  = "flex size-9 items-center justify-center"
end
