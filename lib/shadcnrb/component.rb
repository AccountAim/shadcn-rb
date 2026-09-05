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
      # Span-wrapped like upstream's JSX children — the `[&>span]` hide/truncate
      # rules (sidebar icon-collapse, button truncation) match on it.
      parts << tag.span(name.to_s) if name.present?
      parts << @builder.capture(&block) if block
      return "".html_safe if parts.empty?
      safe_join(parts, " ")
    end

    # Appends a Stimulus action to an existing `data-action` chain, preserving
    # any action the caller already set on `data:`.
    def merge_action(data, *actions)
      [ data&.dig(:action), *actions ].compact.join(" ")
    end

    # Overlay kwargs on trigger-capable helpers (button, link):
    #
    #   sui.button "Edit", dialog: { src: profile_path }   # wraps the button
    #   sui.button "Edit", dialog: "profile-dialog"        # references by id
    #
    # A Hash wraps the rendered element in that overlay as its trigger; the
    # hash is the overlay's own options (`src:`, `loading:`, `side:`, ...).
    # A String stamps `data-<overlay>="<id>"` on the element; the overlay's
    # controller listens document-wide, so the trigger can live anywhere.
    # Anchored overlays position against their trigger, so the String form
    # is modal-only.
    OVERLAY_KWARGS = %i[dialog drawer hover_card dropdown_menu].freeze
    REFERABLE_OVERLAYS = %i[dialog drawer].freeze

    # Pops the overlay kwarg from `opts` before rendering. Returns the
    # [key, config] pair for `wrap_overlay` (Hash form), or nil after
    # stamping the reference attribute (String form).
    def extract_overlay!(opts)
      key = OVERLAY_KWARGS.find { |k| opts.key?(k) }
      return unless key

      value = opts.delete(key)
      return [ key, value ] if value.is_a?(Hash)

      unless REFERABLE_OVERLAYS.include?(key)
        raise ArgumentError, <<~MSG.squish
          #{key}: takes a Hash of #{key} options —
          reference by id only works for #{REFERABLE_OVERLAYS.join(' and ')}
        MSG
      end

      opts[:data] = (opts[:data] || {}).merge(key => value)
      nil
    end

    def wrap_overlay(overlay, html)
      return html unless overlay

      key, config = overlay
      unless @builder.respond_to?(key)
        raise ArgumentError,
          "#{key}: needs the #{key} component — bin/rails g shadcnrb:component #{key}"
      end
      @builder.public_send(key, **config) { |o| o.trigger { html } }
    end

    # `src:` panels: wraps the loading state (block body, else `loading:`,
    # else a default pulse) in a Turbo Frame the controller fetches on first
    # open. The endpoint responds with a `<turbo-frame>` matching the
    # request's `Turbo-Frame` header. With `reload:` the loading state is
    # stashed so it can be restored when the frame resets on close.
    #
    # The frame id is a digest of `src`, so every frame for a given URL
    # sends the same id and the echoed response is safe to cache publicly
    # (browser or CDN). Frames sharing a `src` share the id. `reload:`
    # re-issues the request on every open through normal HTTP caching —
    # the endpoint's cache headers decide how fresh it is.
    def lazy_frame(body, src:, reload:, loading:, slot:)
      loading = body.presence || loading || content_tag(:p, "Loading...",
        class: "text-sm text-muted-foreground animate-pulse")
      frame_opts = { id: "#{slot}-frame-#{Digest::MD5.hexdigest(src.to_s).first(8)}",
                     "data-lazy-src": src }
      if reload
        frame_opts["data-lazy-reload"] = ""
        frame_opts["data-loading-html"] = loading.to_s
      end
      content_tag(:"turbo-frame", loading, **frame_opts)
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
