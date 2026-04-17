# frozen_string_literal: true

module Shadcnrb
  class Progress < Component
    def progress(value: 0, max: 100, **opts)
      pct = max.to_f > 0 ? (value.to_f / max.to_f) * 100 : 0
      pct = pct.clamp(0, 100)
      remaining = 100 - pct

      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
      opts[:"data-slot"] = "progress"
      opts[:"aria-valuemin"] = 0
      opts[:"aria-valuemax"] = max
      opts[:"aria-valuenow"] = value
      opts[:role] = "progressbar"

      content_tag(:div, **opts) do
        tag.div(
          class: self.class.style.indicator,
          style: "transform: translateX(-#{remaining}%)",
          "data-slot": "progress-indicator"
        )
      end
    end
  end
end
