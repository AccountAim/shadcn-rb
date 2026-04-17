# frozen_string_literal: true

# Single entry point for swapping structural styles:
#
#   Shadcnrb::Style.apply(:neobrutalism)   # flip to Shadcnrb::Styles::Neobrutalism
#   Shadcnrb::Style.reset                  # back to the built-in Style per component
#
# A named style module under `Shadcnrb::Styles::<Name>` just declares its
# override classes (one per component, matching the component constant name);
# no `COMPONENTS` hash, no per-style `apply!` boilerplate.
module Shadcnrb
  module Style
    module_function

    def apply(name)
      reset
      return if name.blank? || name.to_s == "default"

      namespace = Shadcnrb::Styles.const_get(name.to_s.camelize)
      namespace.constants(false).each do |const|
        override = namespace.const_get(const)
        next unless override.is_a?(Class)
        component = Shadcnrb.const_get(const)
        component.style = override.new
      rescue NameError
        next
      end
    end

    def reset
      each_component do |component|
        next unless component.const_defined?(:Style, false)
        component.style = component.const_get(:Style).new
      end
    end

    # Walk the component classes installed into the host Builder. We scan the
    # Builder's ancestors for `Shadcnrb::<Name>::Component` delegator modules
    # (the thing the Builder actually `include`s) and map each back to its
    # rendering class — `Shadcnrb::<Name>`.
    def each_component(&block)
      Shadcnrb::Builder.ancestors.each do |ancestor|
        next unless ancestor.name&.match?(/\AShadcnrb::\w+::Component\z/)
        parent = ancestor.name.sub(/::Component\z/, "").safe_constantize
        next unless parent && parent.is_a?(Class) && parent < Shadcnrb::Component
        yield parent
      end
    end
  end
end
