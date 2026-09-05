# frozen_string_literal: true

class Shadcnrb::Table::Style
  def container       = "relative w-full overflow-x-auto"
  def fixed_container = "flex h-full min-h-0 w-full flex-col"

  # The container is the header part: it draws the header rule so it spans the
  # reserved scrollbar gutter, and the inner table's rules are suppressed.
  def fixed_header
    <<~CLASSES.squish
      shrink-0 overflow-hidden border-b [scrollbar-gutter:stable]
      [&_thead]:border-b-0 [&_tr]:border-b-0
    CLASSES
  end

  def fixed_body = "min-h-0 flex-1 overflow-auto [scrollbar-gutter:stable]"

  def base    = "w-full caption-bottom text-sm"
  def header  = "border-b"
  def body    = "[&_tr:last-child]:border-0"
  def footer  = "border-t bg-muted/50 font-medium [&>tr]:last:border-b-0"
  def row     = "border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted"
  def head    = "h-10 px-2 text-left align-middle font-medium whitespace-nowrap text-muted-foreground [&:has([role=checkbox])]:pr-0"
  def cell    = "p-2 align-middle whitespace-nowrap [&:has([role=checkbox])]:pr-0"
  def caption = "mt-4 text-sm text-muted-foreground"

  # Row height and padding per size; `head` and `cell` carry the default.
  def sizes
    {
      default: "",
      lg:      "[&_th]:h-12 [&_th]:px-4 [&_td]:px-4 [&_td]:py-3"
    }
  end
end
