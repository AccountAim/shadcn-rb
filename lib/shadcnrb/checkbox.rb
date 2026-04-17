# frozen_string_literal: true

# shadcn divergence: native `<input type="checkbox">` with a CSS-embedded SVG
# checkmark (data URL) instead of Radix `CheckboxPrimitive.Root` / `Indicator`
# / `CheckIcon`. upstream: checkbox.tsx.

module Shadcnrb
  class Checkbox < Component
    def checkbox(**opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.base, opts[:class])
      opts[:type] = "checkbox"
      opts[:data] = (opts[:data] || {}).merge(slot: "checkbox")
      tag.input(**opts)
    end
  end
end
