# frozen_string_literal: true

class Shadcnrb::NavigationMenu::Style
  def root    = "relative z-10 flex max-w-max flex-1 items-center justify-center"
  def list    = "group flex flex-1 list-none items-center justify-center gap-1"
  def item    = "relative"
  def link    = "inline-flex h-9 w-max items-center justify-center rounded-md bg-background px-4 py-2 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 data-[active=true]:bg-accent data-[active=true]:text-accent-foreground [&>a]:block [&>a]:w-full [&>button]:block [&>button]:w-full"
  def trigger = "inline-flex h-9 w-max cursor-pointer items-center justify-center gap-1 rounded-md bg-background px-4 py-2 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 data-[state=open]:bg-accent data-[state=open]:text-accent-foreground"
  def content = "absolute left-0 top-full mt-1 z-50 w-max min-w-56 rounded-md border bg-popover p-2 text-popover-foreground shadow-md hidden data-[state=open]:block"
end
