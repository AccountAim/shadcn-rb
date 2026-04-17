# frozen_string_literal: true

# shadcn divergence: `<button role="switch">` driven by Stimulus
# `shadcnrb--switch--component` controller (not Radix `SwitchPrimitive`). Adds a hidden
# `<input>` pair so the control round-trips through Rails form submissions
# without JS (the named input's `name` flips between checked/unchecked on
# toggle). upstream: switch.tsx.

module Shadcnrb
  class Switch < Component
    def switch(name: nil, checked: false, value: "1", unchecked_value: "0", include_hidden: true,
      disabled: false, size: :default, aria_label: nil, **opts)
      state = checked ? "checked" : "unchecked"

      opts[:"aria-label"] = aria_label if aria_label
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
      opts[:role] = "switch"
      opts[:"aria-checked"] = checked.to_s
      opts[:data] = (opts[:data] || {}).merge(
        slot: "switch",
        state:,
        size: size.to_s,
        controller: "shadcnrb--switch--component",
        action: "click->shadcnrb--switch--component#toggle"
      )
      opts[:disabled] = true if disabled
      opts[:type] ||= "button"

      button_tag(**opts) do
        parts = []

        if name && include_hidden
          # Unchecked hidden always submits; named value input only submits when checked
          parts << tag.input(type: "hidden", name:, value: unchecked_value)
          parts << tag.input(
            type: "hidden",
            name: checked ? name : nil,
            value:,
            data: { "shadcnrb--switch--component-target": "input", "switch-value": value,
                    "switch-name": name }
          )
        end

        parts << tag.span("", class: self.class.style.thumb,
          data: { slot: "switch-thumb", state: })
        safe_join(parts)
      end
    end
  end
end
