# frozen_string_literal: true

class Shadcnrb::DropdownMenu::Style
  def root = "relative"

  # `hidden` (not `opacity-0`) when closed so the panel leaves layout —
  # otherwise absolutely-positioned triggers near the viewport edge
  # cause horizontal overflow on the whole page.
  #
  # No `overflow-hidden` — it would clip cascading sub-panels anchored
  # outside the parent content. `p-1` keeps interior items clear of the
  # rounded corners on its own.
  def content
    "absolute z-50 mt-2 min-w-[8rem] rounded-md border bg-popover p-1 " \
      "text-popover-foreground shadow-md " \
      "hidden data-[state=open]:block"
  end

  def label     = "px-2 py-1.5 text-sm font-medium"
  def separator = "-mx-1 my-1 h-px bg-border"
  def group     = ""
  def shortcut  = "ml-auto text-xs tracking-widest opacity-60"

  # Flex selectors on `&>a`/`&>button`/`&>form` make the block-form child
  # (e.g. a consumer-supplied `link_to` or `button_to`) fill the row so
  # clicks land anywhere inside. The `text-left` fights `<button>`'s
  # `text-align: center` default for the shortcut form.
  def item
    "relative flex w-full cursor-pointer items-center gap-2 rounded-sm px-2 py-1.5 text-left text-sm " \
      "outline-none select-none hover:bg-accent hover:text-accent-foreground " \
      "disabled:pointer-events-none disabled:opacity-50 " \
      "[&>a]:flex-1 [&>button]:flex-1 [&>form]:flex-1 [&>form>button]:w-full [&>form>button]:text-left"
  end

  # Sub-menu trigger inherits item's flex row + hover but adds open-state
  # accent so the row stays highlighted while its sub-content is open.
  def sub_trigger
    "#{item} justify-between data-[state=open]:bg-accent data-[state=open]:text-accent-foreground"
  end

  # Sub-content anchors to the right of the parent item instead of below
  # the parent trigger. No `overflow-hidden` — nested sub-sub panels
  # extend outside this box (3-level cascades) and would otherwise clip.
  def sub_content
    "absolute left-full top-0 ml-1 z-50 min-w-[8rem] rounded-md border bg-popover p-1 " \
      "text-popover-foreground shadow-md " \
      "hidden data-[state=open]:block"
  end
end
