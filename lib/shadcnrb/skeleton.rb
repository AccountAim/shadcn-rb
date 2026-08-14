# frozen_string_literal: true

module Shadcnrb
  # A pulsing placeholder block. Shape it entirely with utilities — the
  # component brings only the pulse and the surface color. upstream:
  # skeleton.tsx.
  #
  #   sui.skeleton class: "h-4 w-32"
  #   sui.skeleton class: "size-10 rounded-full"
  class Skeleton < Component
    def skeleton(**opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.base, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "skeleton")
      content_tag(:div, "", opts)
    end
  end
end
