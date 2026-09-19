# frozen_string_literal: true

# Column tracks come from the columns and sit on the table as `--cols`; below
# a 36rem container width (`@xl`) each row is a two-column card.
class Shadcnrb::DataGrid::Style
  # Plain layout: one grid, the container scrolls sideways.
  def container = "@container w-full overflow-x-auto"
  def base      = "grid gap-3 text-sm @xl:gap-0 @xl:grid-cols-(--cols)"

  # Fixed header: header, body and footer are separate grids stacked in a
  # column, the body alone scrolls, and the container fills its parent's
  # height.
  def fixed_container = "@container h-full min-h-0 w-full"
  def fixed_base      = "flex h-full min-h-0 flex-col text-sm"

  # Plain row groups are `contents`, so rows are items of the table grid.
  def header = "hidden @xl:contents"
  def body   = "contents [&>[role=row]:last-child]:border-b-0"
  def footer = "hidden @xl:contents [&>[role=row]]:bg-muted/50 [&>[role=row]]:font-medium [&>[role=row]:first-child]:border-t [&>[role=row]:last-child]:border-b-0"

  # Fixed layout: header and footer are clipped grids panned by the
  # controller; all three groups reserve the scrollbar gutter so their tracks
  # line up. The header rule moves onto the group so it spans the gutter.
  def fixed_header = "hidden shrink-0 @xl:grid @xl:grid-cols-(--cols) @xl:overflow-hidden @xl:[scrollbar-gutter:stable] @xl:border-b [&>[role=row]]:border-b-0"
  def fixed_body   = "grid min-h-0 flex-1 gap-3 overflow-auto [scrollbar-gutter:stable] [&>[role=row]:last-child]:border-b-0 @xl:gap-0 @xl:grid-cols-(--cols)"
  def fixed_footer = "hidden shrink-0 border-t bg-muted/50 font-medium @xl:grid @xl:grid-cols-(--cols) @xl:overflow-hidden @xl:[scrollbar-gutter:stable] [&>[role=row]:last-child]:border-b-0"

  # A card below the breakpoint, a subgrid of the table above it. `group`
  # lets pinned cells follow the row hover.
  def row = "group grid grid-cols-[1fr_auto] gap-x-3 rounded-lg border p-3 transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted @xl:col-span-full @xl:grid-cols-subgrid @xl:gap-x-0 @xl:rounded-none @xl:border-x-0 @xl:border-t-0 @xl:p-0"

  def head = "flex h-10 items-center px-2.5 font-medium whitespace-nowrap text-muted-foreground [&:has([role=checkbox])]:pr-0"

  # A block with centred content rather than a flex box, so `truncate` works
  # on the cell itself. Card placement is reset at the breakpoint: grid cells
  # honour it.
  def cell = "px-0 py-1 @xl:col-auto @xl:row-auto @xl:justify-self-auto @xl:block @xl:content-center @xl:px-2.5 @xl:py-2 [&:has([role=checkbox])]:pr-0"

  def caption = "order-last mt-4 text-sm text-muted-foreground @xl:col-span-full"

  # Where a cell lands in the card; the default is a label / value line with
  # the heading pulled from `data-label`.
  def cards
    {
      title:   "col-start-1 row-start-1 text-base font-semibold @xl:text-sm @xl:font-medium",
      aside:   "col-start-2 row-start-1 justify-self-end",
      footer:  "col-span-2 mt-2 border-t pt-2 @xl:mt-0 @xl:border-0 @xl:py-1",
      hidden:  "hidden @xl:block",
      default: "col-span-2 flex justify-between gap-4 before:content-[attr(data-label)] before:text-muted-foreground @xl:before:content-none"
    }
  end

  def card_order = "order-(--card-order) @xl:order-none"

  # Flexible cells may shrink below their text; `auto` tracks must not.
  def flexible = "flex-col items-start gap-0.5 @xl:min-w-0"
  def wrap     = "@xl:whitespace-normal"
  def nowrap   = "@xl:whitespace-nowrap"
  def truncate = "@xl:truncate"

  def align_end      = "@xl:text-right"
  def head_align_end = "justify-end"
  def hidden_heading = "sr-only"

  # Pinned cells paint over scrolled content, so they need a solid background;
  # the hover mix matches the row's translucent hover.
  def pins
    {
      start: "@xl:sticky @xl:left-0 @xl:z-10 @xl:border-r @xl:bg-background",
      end:   "@xl:sticky @xl:right-0 @xl:z-10 @xl:border-l @xl:bg-background"
    }
  end

  def pin_hover = "@xl:group-hover:bg-[color-mix(in_oklab,var(--color-muted)_50%,var(--color-background))] @xl:group-data-[state=selected]:bg-muted"

  # Selection: the table is the tab stop and hands focus to a cell; the
  # selected cell draws an inset outline in the ring colour.
  def selectable      = "outline-none"
  def selectable_cell = "cursor-default outline-none aria-selected:outline-2 aria-selected:outline-solid aria-selected:-outline-offset-2 aria-selected:outline-ring"

  # Row height and padding per size, grid layout only; cards keep their own.
  def sizes
    {
      default: "",
      lg:      "@xl:[&_[data-slot=data-grid-head]]:h-12 @xl:[&_[data-slot=data-grid-head]]:px-4 @xl:[&_[data-slot=data-grid-cell]]:px-4 @xl:[&_[data-slot=data-grid-cell]]:py-3"
    }
  end
end
