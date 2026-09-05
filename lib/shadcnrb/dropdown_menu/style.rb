# frozen_string_literal: true

class Shadcnrb::DropdownMenu::Style
  # The root hugs the trigger — its rect is what the panel anchors to, and
  # click-to-toggle lives on it. Full-width triggers (sidebar footers) add
  # `class: "w-full"` on the wrapper.
  def root = "inline-block"

  # Placement is inline-styled by the anchored controller. `p-1` keeps
  # interior items clear of the rounded corners without `overflow-hidden`.
  def content
    <<~CLASSES.squish
      fixed z-50 min-w-[8rem] rounded-md border bg-popover p-1
      text-popover-foreground shadow-md
      hidden data-[state=open]:block
    CLASSES
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
    <<~CLASSES.squish
      relative flex w-full cursor-pointer items-center gap-2 rounded-sm px-2 py-1.5 text-left text-sm
      outline-none select-none hover:bg-accent hover:text-accent-foreground
      disabled:pointer-events-none disabled:opacity-50
      [&>a]:flex-1 [&>button]:flex-1 [&>form]:flex-1 [&>form>button]:w-full [&>form>button]:text-left
    CLASSES
  end

  # Sub-menu trigger inherits item's flex row + hover but adds open-state
  # accent so the row stays highlighted while its sub-content is open.
  def sub_trigger
    "#{item} justify-between data-[state=open]:bg-accent data-[state=open]:text-accent-foreground"
  end

  # Anchors to the right of the parent item instead of below a trigger.
  def sub_content
    <<~CLASSES.squish
      fixed z-50 min-w-[8rem] rounded-md border bg-popover p-1
      text-popover-foreground shadow-md
      hidden data-[state=open]:block
    CLASSES
  end
end
