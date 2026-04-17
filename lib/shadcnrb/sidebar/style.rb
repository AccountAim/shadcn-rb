# frozen_string_literal: true

class Shadcnrb::Sidebar::Style
  def wrapper = "group/sidebar-wrapper flex h-svh w-full overflow-hidden has-[[data-variant=inset]]:bg-sidebar"

  # Mobile overlay that dims the page when the sidebar is expanded on
  # small viewports. Fades in via group-data state from the wrapper.
  def mobile_backdrop
    "fixed inset-0 z-[5] bg-black/50 opacity-0 pointer-events-none transition-opacity md:hidden " \
      "group-data-[state=expanded]/sidebar-wrapper:opacity-100 " \
      "group-data-[state=expanded]/sidebar-wrapper:pointer-events-auto"
  end

  # collapsible=none variant
  def root_none = "flex h-full w-[var(--sidebar-width)] flex-col bg-sidebar text-sidebar-foreground"

  # outer positioning wrapper (the "group peer" div)
  def root_outer = "group peer text-sidebar-foreground"

  # gap spacer div
  def root_gap_base             = "relative w-[var(--sidebar-width)] bg-transparent transition-[width] duration-200 ease-linear group-data-[collapsible=offcanvas]:w-0 group-data-[side=right]:rotate-180 max-md:w-0!"
  def root_gap_icon_default     = "group-data-[collapsible=icon]:w-[var(--sidebar-width-icon)]"
  def root_gap_icon_floating    = "group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+calc(var(--spacing)*4))]"

  # container (fixed, full height)
  def root_container_base       = "fixed inset-y-0 z-10 flex h-svh w-[var(--sidebar-width)] transition-[left,right,width] duration-200 ease-linear"
  def root_container_left       = "left-0 group-data-[collapsible=offcanvas]:left-[calc(var(--sidebar-width)*-1)]"
  def root_container_right      = "right-0 group-data-[collapsible=offcanvas]:right-[calc(var(--sidebar-width)*-1)]"
  def root_container_icon_default  = "group-data-[collapsible=icon]:w-[var(--sidebar-width-icon)] group-data-[side=left]:border-r group-data-[side=right]:border-l"
  def root_container_icon_floating = "p-2 group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+calc(var(--spacing)*4)+2px)]"

  # inner sidebar div
  def root_inner = "flex h-full w-full flex-col bg-sidebar group-data-[variant=floating]:rounded-lg group-data-[variant=floating]:border group-data-[variant=floating]:border-sidebar-border group-data-[variant=floating]:shadow-sm"

  def header  = "flex flex-col gap-2 p-2"
  def footer  = "flex flex-col gap-2 p-2"
  def content = "flex min-h-0 flex-1 flex-col gap-2 overflow-auto group-data-[collapsible=icon]:overflow-hidden"
  def group   = "relative flex w-full min-w-0 flex-col p-2"

  def group_label   = "flex h-8 shrink-0 items-center rounded-md px-2 text-xs font-medium text-sidebar-foreground/70 ring-sidebar-ring outline-hidden transition-[margin,opacity] duration-200 ease-linear focus-visible:ring-2 [&>svg]:size-4 [&>svg]:shrink-0 group-data-[collapsible=icon]:-mt-8 group-data-[collapsible=icon]:opacity-0"
  def group_action  = "absolute top-3.5 right-3 flex aspect-square w-5 items-center justify-center rounded-md p-0 text-sidebar-foreground ring-sidebar-ring outline-hidden transition-transform hover:bg-sidebar-accent hover:text-sidebar-accent-foreground focus-visible:ring-2 [&>svg]:size-4 [&>svg]:shrink-0 after:absolute after:-inset-2 md:after:hidden group-data-[collapsible=icon]:hidden"
  def group_content = "w-full text-sm"

  def menu      = "flex w-full min-w-0 flex-col gap-1"
  def menu_item = "group/menu-item relative"

  # `group-data-[collapsible=icon]:[&>span,&>div]:hidden` auto-hides label
  # spans and account-info divs in icon-collapsed mode; icons (svg) stay
  # visible.
  def menu_button_base            = "peer/menu-button flex w-full items-center gap-2 overflow-hidden rounded-md p-2 text-left text-sm cursor-pointer ring-sidebar-ring outline-hidden transition-[width,height,padding] group-has-data-[sidebar=menu-action]/menu-item:pr-8 group-data-[collapsible=icon]:size-8! group-data-[collapsible=icon]:p-2! group-data-[collapsible=icon]:[&>span]:hidden group-data-[collapsible=icon]:[&>div]:hidden hover:bg-sidebar-accent hover:text-sidebar-accent-foreground focus-visible:ring-2 active:bg-sidebar-accent active:text-sidebar-accent-foreground disabled:pointer-events-none disabled:opacity-50 aria-disabled:pointer-events-none aria-disabled:opacity-50 data-[active=true]:bg-sidebar-accent data-[active=true]:font-medium data-[active=true]:text-sidebar-accent-foreground data-[state=open]:hover:bg-sidebar-accent data-[state=open]:hover:text-sidebar-accent-foreground [&>span:last-child]:truncate [&>svg]:size-4 [&>svg]:shrink-0 [&>a]:flex-1 [&>button]:flex-1 [&>form]:flex-1 [&>form>button]:w-full [&>form>button]:text-left"
  def menu_button_variant_default = "hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
  def menu_button_variant_outline = "bg-background shadow-[0_0_0_1px_hsl(var(--sidebar-border))] hover:bg-sidebar-accent hover:text-sidebar-accent-foreground hover:shadow-[0_0_0_1px_hsl(var(--sidebar-accent))]"
  def menu_button_size_default    = "h-8 text-sm"
  def menu_button_size_sm         = "h-7 text-xs"
  def menu_button_size_lg         = "h-12 text-sm group-data-[collapsible=icon]:p-0!"
  def menu_button_inactive        = "text-sidebar-foreground"
  def menu_button_active          = "bg-sidebar-accent text-sidebar-accent-foreground font-medium"

  def menu_action_base           = "absolute top-1.5 right-1 flex aspect-square w-5 items-center justify-center rounded-md p-0 text-sidebar-foreground ring-sidebar-ring outline-hidden transition-transform peer-hover/menu-button:text-sidebar-accent-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground focus-visible:ring-2 [&>svg]:size-4 [&>svg]:shrink-0 after:absolute after:-inset-2 md:after:hidden peer-data-[size=sm]/menu-button:top-1 peer-data-[size=default]/menu-button:top-1.5 peer-data-[size=lg]/menu-button:top-2.5 group-data-[collapsible=icon]:hidden"
  def menu_action_show_on_hover  = "group-focus-within/menu-item:opacity-100 group-hover/menu-item:opacity-100 peer-data-[active=true]/menu-button:text-sidebar-accent-foreground data-[state=open]:opacity-100 md:opacity-0"

  def menu_badge          = "pointer-events-none absolute right-1 flex h-5 min-w-5 items-center justify-center rounded-md px-1 text-xs font-medium text-sidebar-foreground tabular-nums select-none peer-hover/menu-button:text-sidebar-accent-foreground peer-data-[active=true]/menu-button:text-sidebar-accent-foreground peer-data-[size=sm]/menu-button:top-1 peer-data-[size=default]/menu-button:top-1.5 peer-data-[size=lg]/menu-button:top-2.5 group-data-[collapsible=icon]:hidden"
  def menu_skeleton       = "flex h-8 items-center gap-2 rounded-md px-2"
  def menu_skeleton_icon  = "size-4 rounded-md bg-sidebar-accent animate-pulse"
  def menu_skeleton_text  = "h-4 flex-1 bg-sidebar-accent animate-pulse rounded-md"

  def menu_sub              = "mx-3.5 flex min-w-0 translate-x-px flex-col gap-1 border-l border-sidebar-border px-2.5 py-0.5 group-data-[collapsible=icon]:hidden"
  def menu_sub_item         = "group/menu-sub-item relative"
  def menu_sub_button_base  = "flex h-7 min-w-0 -translate-x-px items-center gap-2 overflow-hidden rounded-md px-2 text-sidebar-foreground ring-sidebar-ring outline-hidden hover:bg-sidebar-accent hover:text-sidebar-accent-foreground focus-visible:ring-2 active:bg-sidebar-accent active:text-sidebar-accent-foreground disabled:pointer-events-none disabled:opacity-50 aria-disabled:pointer-events-none aria-disabled:opacity-50 [&>span:last-child]:truncate [&>svg]:size-4 [&>svg]:shrink-0 [&>svg]:text-sidebar-accent-foreground data-[active=true]:bg-sidebar-accent data-[active=true]:text-sidebar-accent-foreground group-data-[collapsible=icon]:hidden [&>a]:flex-1 [&>button]:flex-1 [&>form]:flex-1 [&>form>button]:w-full [&>form>button]:text-left"
  def menu_sub_button_size_sm = "text-xs"
  def menu_sub_button_size_md = "text-sm"

  def separator     = "mx-2 w-auto border-sidebar-border"
  def inset         = "relative flex w-full flex-1 flex-col bg-background min-h-0 md:peer-data-[variant=inset]:m-2 md:peer-data-[variant=inset]:ml-0 md:peer-data-[variant=inset]:rounded-xl md:peer-data-[variant=inset]:shadow-sm md:peer-data-[variant=inset]:peer-data-[state=collapsed]:ml-2 overflow-hidden"
  def inset_header  = "flex h-14 shrink-0 items-center gap-2 border-b px-6 bg-background"
  def inset_content = "flex-1 overflow-y-auto"

  def trigger = "inline-flex items-center justify-center rounded-md h-7 w-7 text-sm cursor-pointer hover:bg-accent hover:text-accent-foreground"

  def rail
    "absolute inset-y-0 z-20 hidden w-4 -translate-x-1/2 transition-all ease-linear " \
      "after:absolute after:inset-y-0 after:left-1/2 after:w-[2px] " \
      "hover:after:bg-sidebar-border group-data-[side=left]:right-0 group-data-[side=right]:left-0 sm:flex"
  end
end
