# frozen_string_literal: true

class Shadcnrb::Collapsible::Style
  # `group/collapsible` is folded in so descendant elements can target
  # state via `group-data-[state=open]/collapsible:*` without callers
  # needing to remember the class.
  def root    = "group/collapsible"
  def chevron = "ml-auto size-4 transition-transform group-data-[state=open]/collapsible:rotate-180"
  def content = "hidden data-[state=open]:block"
end
