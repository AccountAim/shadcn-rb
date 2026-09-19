# frozen_string_literal: true

# Column tracks come from the columns and sit on the table as `--cols`. The
# `@cards:` step is 1em of the wrapper, whose font-size the component sets to
# the card breakpoint (0 when cards are off); below it each row is a card.
class Shadcnrb::DataGrid::Style
  # Plain layout: one grid, the container scrolls sideways.
  def container = "@container w-full overflow-x-auto"
  def base      = "grid gap-3 text-sm @cards:gap-0 @cards:grid-cols-(--cols)"

  # Fixed header: header, body and footer are separate grids stacked in a
  # column, the body alone scrolls, and the container fills its parent's
  # height.
  def fixed_container = "@container h-full min-h-0 w-full"
  def fixed_base      = "flex h-full min-h-0 flex-col text-sm"

  # Plain row groups are `contents`, so rows are items of the table grid. A
  # non-row child of the body (a loader frame, say) spans every column.
  def header = "hidden @cards:contents"
  def body   = "contents [&>[role=row]:last-child]:border-b-0 [&>:not([role=row])]:col-span-full"
  def footer = "hidden @cards:contents [&>[role=row]]:bg-muted/50 [&>[role=row]]:font-medium [&>[role=row]:first-child]:border-t [&>[role=row]:last-child]:border-b-0"

  # Fixed layout: header and footer are clipped grids panned by the
  # controller; all three groups reserve the scrollbar gutter so their tracks
  # line up. The header rule moves onto the group so it spans the gutter.
  def fixed_header = "hidden shrink-0 @cards:grid @cards:grid-cols-(--cols) @cards:overflow-hidden @cards:[scrollbar-gutter:stable] @cards:border-b [&>[role=row]]:border-b-0"
  def fixed_body   = "grid min-h-0 flex-1 gap-3 overflow-auto [scrollbar-gutter:stable] [&>[role=row]:last-child]:border-b-0 [&>:not([role=row])]:col-span-full @cards:gap-0 @cards:grid-cols-(--cols)"
  def fixed_footer = "hidden shrink-0 border-t bg-muted/50 font-medium @cards:grid @cards:grid-cols-(--cols) @cards:overflow-hidden @cards:[scrollbar-gutter:stable] [&>[role=row]:last-child]:border-b-0"

  # A card below the breakpoint, a subgrid of the table above it. `group`
  # lets pinned cells follow the row hover.
  def row = "group grid grid-cols-[1fr_auto] gap-x-3 rounded-lg border p-3 transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted @cards:col-span-full @cards:grid-cols-subgrid @cards:gap-x-0 @cards:rounded-none @cards:border-x-0 @cards:border-t-0 @cards:p-0"

  def head = "flex h-10 items-center px-2.5 font-medium whitespace-nowrap text-muted-foreground [&:has([role=checkbox])]:pr-0"

  # A block with centred content rather than a flex box, so `truncate` works
  # on the cell itself. Card placement is reset at the breakpoint: grid cells
  # honour it. `group/cell` lets the tooltip wrapper follow the cell's mode.
  def cell = "group/cell px-0 py-1 @cards:col-auto @cards:row-auto @cards:justify-self-auto @cards:block @cards:content-center @cards:px-2.5 @cards:py-2 data-[mode=editing]:overflow-visible data-[mode=editing]:whitespace-normal [&:has([role=checkbox])]:pr-0"

  def caption = "mt-4 text-sm text-muted-foreground"

  # Where a cell lands in the card; the default is a label / value line with
  # the heading pulled from `data-label`.
  def cards
    {
      title:   "col-start-1 row-start-1 text-base font-semibold @cards:text-sm @cards:font-medium",
      aside:   "col-start-2 row-start-1 justify-self-end",
      footer:  "col-span-2 mt-2 border-t pt-2 @cards:mt-0 @cards:border-0 @cards:py-1",
      hidden:  "hidden @cards:block",
      default: "col-span-2 flex justify-between gap-4 before:content-[attr(data-label)] before:text-muted-foreground @cards:before:content-none"
    }
  end

  def card_order = "order-(--card-order) @cards:order-none"

  # Flexible cells may shrink below their text; `auto` tracks must not.
  def flexible = "flex-col items-start gap-0.5 @cards:min-w-0"
  def wrap     = "@cards:whitespace-normal"
  def nowrap   = "@cards:whitespace-nowrap"
  def truncate = "@cards:truncate"
  # Truncation is a viewing-state thing: an editing cell shows its editor whole.
  def tooltip  = "@cards:block @cards:truncate group-data-[mode=editing]/cell:overflow-visible group-data-[mode=editing]/cell:whitespace-normal"

  def align_end      = "@cards:text-right"
  def head_align_end = "justify-end"
  def hidden_heading = "sr-only"

  # Pinned cells paint over scrolled content, so they need a solid background;
  # the hover mix matches the row's translucent hover.
  def pins
    {
      start: "@cards:sticky @cards:left-0 @cards:z-10 @cards:border-r @cards:bg-background",
      end:   "@cards:sticky @cards:right-0 @cards:z-10 @cards:border-l @cards:bg-background"
    }
  end

  def pin_hover = "@cards:group-hover:bg-[color-mix(in_oklab,var(--color-muted)_50%,var(--color-background))] @cards:group-data-[state=selected]:bg-muted"

  # Selection: the table is the tab stop and hands focus to a cell; the
  # selected cell draws an inset outline in the ring colour.
  def selectable      = "outline-none"
  def selectable_cell = "cursor-default outline-none aria-selected:outline-2 aria-selected:outline-solid aria-selected:-outline-offset-2 aria-selected:outline-ring"

  # Row height and padding per size, grid layout only; cards keep their own.
  def sizes
    {
      default: "",
      lg:      "@cards:[&_[data-slot=data-grid-head]]:h-12 @cards:[&_[data-slot=data-grid-head]]:px-4 @cards:[&_[data-slot=data-grid-cell]]:px-4 @cards:[&_[data-slot=data-grid-cell]]:py-3"
    }
  end
end
