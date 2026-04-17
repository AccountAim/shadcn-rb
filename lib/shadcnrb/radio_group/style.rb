# frozen_string_literal: true

class Shadcnrb::RadioGroup::Style
  def root = "grid gap-3"
  def item = "peer size-4 shrink-0 cursor-pointer appearance-none rounded-full border border-input shadow-xs transition-[color,box-shadow] outline-none checked:border-primary focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 checked:bg-[radial-gradient(circle_at_center,var(--color-primary)_0_45%,transparent_50%_100%)]"
end
