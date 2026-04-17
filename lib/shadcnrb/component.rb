# frozen_string_literal: true

# shadcn divergence (global): components carry no inline `dark:` utilities —
# dark mode flips CSS tokens at `:root.dark` in `application.css`.
#
# shadcn divergence (global): `cursor-pointer` on interactive elements where
# upstream uses `cursor-default`.

module Shadcnrb
  # Base class for every component. Each component is `Shadcnrb::<Name> <
  # Shadcnrb::Component` and holds a reference to the host Builder; unknown
  # methods (`content_tag`, `safe_join`, `capture`, `button`, `icon`, …) fall
  # through to the Builder via `delegate_missing_to`, so component code reads
  # as if it were on the Builder itself.
  #
  # Swap a component's look by assigning a subclass instance:
  #
  #   Shadcnrb::Button.style = NeobrutalistButtonStyle.new
  class Component
    class << self
      attr_writer :style

      # Each component's `Style` class lives alongside it at
      # `Shadcnrb::<Name>::Style`.
      def style
        @style ||= const_get(:Style).new
      end
    end

    def initialize(builder)
      @builder = builder
    end

    delegate_missing_to :@builder

    private

    # `style` must respond to `base` and optionally `variants` / `sizes` (each
    # returning a Hash of Symbol → String). `component:` is inferred from the
    # style's class — `Shadcnrb::Alert::Style` → `"alert"` — so callers don't
    # have to pass it.
    def classes_from_style(style, variant: nil, size: nil, custom: nil, component: nil)
      component ||= style.class.name&.split("::")&.[](-2)&.downcase || "component"
      parts = [ style.base ]
      if variant
        parts << Shadcnrb::TailwindMerge.fetch_variant(
          style.variants, variant, kind: :variant, component:
        )
      end
      if size
        parts << Shadcnrb::TailwindMerge.fetch_variant(
          style.sizes, size, kind: :size, component:
        )
      end
      parts << custom if custom
      Shadcnrb::TailwindMerge.call(*parts)
    end

    # Joins an optional icon, a `name` string, and a captured block in that
    # order — so callers can pass any combination (icon+name, icon+block,
    # name+block for trailing chevrons, etc.) without manual composition.
    def content_with_icon(name = nil, icon: nil, &block)
      parts = []
      parts << self.icon(icon) if icon
      parts << name.to_s      if name.present?
      parts << @builder.capture(&block) if block
      return "".html_safe if parts.empty?
      safe_join(parts, " ")
    end

    # Appends a Stimulus action to an existing `data-action` chain, preserving
    # any action the caller already set on `data:`.
    def merge_action(data, *actions)
      [ data&.dig(:action), *actions ].compact.join(" ")
    end

    # `current_page?` raises when passed `"#"` or a malformed hash. Wrap so
    # callers don't have to special-case placeholders or rescue in views.
    def safe_current_page?(options)
      return false if options.nil? || options == "#"
      @builder.current_page?(options)
    rescue StandardError
      false
    end
  end
end
