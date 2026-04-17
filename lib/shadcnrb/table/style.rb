# frozen_string_literal: true

class Shadcnrb::Table::Style
  def container = "relative w-full overflow-x-auto"
  def base      = "w-full caption-bottom text-sm"
  def header    = "[&_tr]:border-b"
  def body      = "[&_tr:last-child]:border-0"
  def footer    = "border-t bg-muted/50 font-medium [&>tr]:last:border-b-0"
  def row       = "border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted"
  def head      = "h-10 px-2 text-left align-middle font-medium whitespace-nowrap text-muted-foreground [&:has([role=checkbox])]:pr-0"
  def cell      = "p-2 align-middle whitespace-nowrap [&:has([role=checkbox])]:pr-0"
  def caption   = "mt-4 text-sm text-muted-foreground"
end
