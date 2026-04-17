# frozen_string_literal: true

class Shadcnrb::Switch::Style
  def root
    "peer group/switch inline-flex shrink-0 items-center rounded-full border border-transparent shadow-xs transition-all outline-none cursor-pointer " \
      "focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 " \
      "disabled:cursor-not-allowed disabled:opacity-50 " \
      "data-[size=default]:h-[1.15rem] data-[size=default]:w-8 " \
      "data-[size=sm]:h-3.5 data-[size=sm]:w-6 " \
      "data-[state=checked]:bg-primary data-[state=unchecked]:bg-input"
  end

  def thumb
    "pointer-events-none block rounded-full bg-background ring-0 transition-transform " \
      "group-data-[size=default]/switch:size-4 group-data-[size=sm]/switch:size-3 " \
      "data-[state=checked]:translate-x-[calc(100%-2px)] data-[state=unchecked]:translate-x-0"
  end
end
