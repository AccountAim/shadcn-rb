# frozen_string_literal: true

module Shadcnrb
  # Swap the whole look by assigning a subclass instance:
  #
  #   class NeobrutalistButton < Shadcnrb::Button::Style
  #     def base = "#{super} border-4 border-black shadow-[4px_4px_0_0_#000]"
  #     def variants = super.merge(default: "bg-yellow-300 text-black hover:bg-yellow-400")
  #   end
  #   Shadcnrb::Button.style = NeobrutalistButton.new
  #
  # `variant: :bare` skips class + `data-slot` defaults so callers can plug a
  # styled wrapper inside a row-styled parent (e.g. a dropdown item) without
  # stacking button visuals. When the call comes through a non-top-level
  # scope (`i.link_to` inside `m.item do |i| ... end`), the scope passes
  # itself as `scope:` and we resolve `variant` from there — no need for
  # callers to write `variant: :bare`.
  class Button < Component
    BARE_VARIANT = :bare

    def button(name = nil, variant: nil, size: :default, icon: nil, scope: nil, **opts, &block)
      variant = resolve_variant(variant, scope)
      # `icon:` with no text/block → render as an icon button at the icon
      # size unless the caller picked one explicitly.
      size = :icon if icon && name.nil? && !block && size == :default
      opts[:type] = opts[:type] ? opts[:type].to_s : "button"
      unless variant == BARE_VARIANT
        opts[:class] = classes(variant, size, opts[:class])
        # Caller-supplied data (e.g. `data: { slot: "dialog-trigger" }`) takes
        # precedence so composed callers can override the default `slot: button`.
        opts[:data] =
          { slot: "button", variant: variant.to_s, size: size.to_s }.merge(opts[:data] || {})
      end
      button_tag(**opts) do
        content_with_icon(name, icon:, &block)
      end
    end

    def button_to(name = nil, options = nil, variant: nil, size: :default, icon: nil,
      scope: nil, **html_opts, &block)
      variant = resolve_variant(variant, scope)
      unless variant == BARE_VARIANT
        html_opts[:class] = classes(variant, size, html_opts[:class])
        html_opts[:data] =
          { slot: "button", variant: variant.to_s, size: size.to_s }.merge(html_opts[:data] || {})
      end
      if block || icon
        @builder.view_context.button_to(options || name, html_opts) do
          content_with_icon(name, icon:, &block)
        end
      else
        @builder.view_context.button_to(name, options, html_opts)
      end
    end

    private

    def classes(variant, size, custom)
      classes_from_style(self.class.style, variant:, size:, custom:)
    end

    # Caller's explicit `variant:` always wins. When unset, default to
    # `:bare` if a non-top-level scope is in play (e.g. a dropdown item's
    # `i.button_to`), otherwise `:default`. Top-level scope calls (proxy
    # yielded directly by the component) keep the styled default.
    def resolve_variant(variant, scope)
      return variant unless variant.nil?
      scope&.parent ? BARE_VARIANT : :default
    end
  end
end
