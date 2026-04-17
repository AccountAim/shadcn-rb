# frozen_string_literal: true

class Shadcnrb::Card::Style
  def root        = "flex flex-col gap-6 rounded-xl border bg-card py-6 text-card-foreground shadow-sm"
  def header      = "@container/card-header grid auto-rows-min grid-rows-[auto_auto] items-start gap-2 px-6 has-data-[slot=card-action]:grid-cols-[1fr_auto] [.border-b]:pb-6"
  def title       = "leading-none font-semibold"
  def description = "text-sm text-muted-foreground"
  def action      = "col-start-2 row-span-2 row-start-1 self-start justify-self-end"
  def content     = "px-6"
  def footer      = "flex items-center px-6 [.border-t]:pt-6"
end
