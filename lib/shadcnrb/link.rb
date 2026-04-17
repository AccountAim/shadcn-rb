# frozen_string_literal: true

module Shadcnrb
  # `sui.link_to` is the one anchor helper. Mirrors Rails' `link_to` signature
  # exactly; picks its visuals from `variant:`. Prose variants (`:link`
  # default, `:underline`, `:muted`, `:foreground`) use the Link style
  # table. Button-style variants (`:default`, `:destructive`, `:outline`,
  # `:secondary`, `:ghost`) delegate to `Shadcnrb::Button.style` — no
  # duplication.
  class Link < Component
    PROSE_VARIANTS  = %i[link underline muted foreground].freeze
    BUTTON_VARIANTS = %i[default destructive outline secondary ghost].freeze
    # Internal escape hatch for wrappers (breadcrumb_link, dropdown_menu_item,
    # sidebar_menu_button, navigation_menu_link): delegate to `link_to`
    # for `icon:` + Rails plumbing but skip Link's Style base so the
    # caller's own component classes win.
    BARE_VARIANT = :bare

    # Mirrors Rails' `link_to` signature.
    #
    #   sui.link_to "Read more", post_path(post)                 # prose underline (default)
    #   sui.link_to "Edit",      edit_path, variant: :outline    # outline button-styled
    #   sui.link_to "Delete",    record_path(r), variant: :destructive,
    #                         method: :delete, data: { turbo_confirm: "Sure?" }
    #   sui.link_to "More",      more_path, variant: :ghost, size: :sm
    def link_to(name = nil, options = nil, variant: nil, size: :default, icon: nil,
      scope: nil, **html_opts, &block)
      # Caller's `variant:` always wins. Otherwise default to `:bare` when
      # called inside a non-top-level scope (e.g. `i.link_to` from a
      # dropdown item) so the wrapper's row styling isn't overlaid. Top-
      # level scope calls (`m.link_to` directly on a yielded proxy) keep
      # the regular `:link` default.
      variant ||= scope&.parent ? BARE_VARIANT : :link
      html_opts[:class] = link_classes(variant.to_sym, size.to_sym, html_opts[:class])
      if block || icon
        body = content_with_icon(name, icon:, &block)
        @builder.view_context.link_to(options || name || "#", html_opts) { body }
      else
        @builder.view_context.link_to(name, options, html_opts)
      end
    end

    private

    def link_classes(variant, size, custom)
      return custom.to_s if variant == BARE_VARIANT
      if PROSE_VARIANTS.include?(variant)
        classes_from_style(self.class.style, variant:, size:, custom:, component: "link")
      elsif BUTTON_VARIANTS.include?(variant)
        classes_from_style(Shadcnrb::Button.style, variant:, size:, custom:, component: "link")
      else
        valid = (PROSE_VARIANTS + BUTTON_VARIANTS).map(&:inspect).join(", ")
        raise ArgumentError, "Unknown link variant #{variant.inspect}. Valid: [#{valid}]"
      end
    end
  end
end
