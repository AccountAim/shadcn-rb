# frozen_string_literal: true

# shadcn divergence: native `<input type="radio">` + CSS radial-gradient dot
# instead of Radix `RadioGroupPrimitive.Root` + `Item` + `Indicator` +
# `CircleIcon`. Rails-first, same reasoning as Checkbox. upstream:
# radio-group.tsx.
#
# shadcn divergence: child `item` is orphan-protected — it only renders when
# called through a `:radio_group`-kind `Shadcnrb::Scope` (yielded by
# `sui.radio_group do |rg| ... end`, or via `sui.radio_group_proxy`).

module Shadcnrb
  class RadioGroup < Component
    def radio_group(**opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
      opts[:role] = "radiogroup"
      opts[:data] = (opts[:data] || {}).merge(slot: "radio-group")
      content_tag(:div, **opts) do
        block ? capture(proxy, &block) : "".html_safe
      end
    end

    def proxy
      Scope.new(@builder, kind: :radio_group, component: self)
    end

    def item(name:, value:, scope: nil, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.item, opts[:class])
      opts[:type] = "radio"
      opts[:name] = name
      opts[:value] = value
      opts[:data] = (opts[:data] || {}).merge(slot: "radio-group-item")
      tag.input(**opts)
    end

    private :item
  end
end
