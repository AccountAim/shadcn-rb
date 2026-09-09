# frozen_string_literal: true

module Shadcnrb
  class ThemeSwitcher < Component
    # Ships with these theme keys. Extend by adding `.sui-theme-<name>` blocks
    # in your CSS and passing your own `themes:` list.
    DEFAULT_THEMES = [
      { key: "default", label: "Default", swatch: "bg-neutral-900" },
      { key: "blue",    label: "Blue",    swatch: "bg-blue-500" },
      { key: "green",   label: "Green",   swatch: "bg-green-500" },
      { key: "rose",    label: "Rose",    swatch: "bg-rose-500" },
      { key: "violet",  label: "Violet",  swatch: "bg-violet-500" },
      { key: "orange",  label: "Orange",  swatch: "bg-orange-500" }
    ].freeze

    # Classes for `<html>`, so the server renders the chosen palette and
    # nothing flashes on load. `theme:` / `mode:` come from wherever the app
    # keeps them; nil falls through to the `shadcnrb_theme` / `shadcnrb_mode`
    # cookies the switcher writes:
    #
    #   <html class="<%= sui.theme_class %>">
    #   <html class="<%= sui.theme_class(theme: user.theme, mode: user.mode) %>">
    def theme_class(theme: nil, mode: nil)
      cookies = @builder.view_context.cookies
      theme = (theme || cookies["shadcnrb_theme"]).to_s[/\A[a-z0-9-]+\z/]
      mode ||= cookies["shadcnrb_mode"]
      [
        ("sui-theme-#{theme}" if theme && theme != "default"),
        ("dark" if mode.to_s == "dark")
      ].compact.join(" ")
    end

    # Renders a dropdown with theme swatches + a dark/light toggle. Pair with
    # `theme_class` on `<html>`. Every pick writes the cookies and dispatches
    # `shadcnrb--theme-switcher--component:change` with `{ theme, mode }` —
    # listen to that to persist the choice server-side.
    #
    #   <%= sui.theme_switcher %>
    #   <%= sui.theme_switcher themes: [
    #         { key: "brand", label: "Brand", swatch: "bg-violet-500" }
    #       ] %>
    def theme_switcher(themes: DEFAULT_THEMES, **opts)
      opts[:data] = (opts[:data] || {}).merge(controller: "shadcnrb--theme-switcher--component")

      dropdown_menu(content: { class: "w-56" }, **opts) do |m|
        safe_join([
          m.trigger do
            button(variant: :outline) do
              safe_join([
                tag.span("", class: "size-4 rounded-full bg-primary"),
                tag.span("Theme")
              ])
            end
          end,
          tag.div("Theme", class: "px-2 py-1.5 text-xs font-medium text-muted-foreground"),
          content_tag(:div, class: "grid grid-cols-3 gap-1 p-1") do
            safe_join(themes.map { |t| theme_swatch_button(t) })
          end,
          tag.div("", class: "my-1 h-px bg-border"),
          tag.div("Mode", class: "px-2 py-1.5 text-xs font-medium text-muted-foreground"),
          content_tag(:div, class: "grid grid-cols-2 gap-1 p-1") do
            safe_join([
              mode_button("light", "Light"),
              mode_button("dark",  "Dark")
            ])
          end
        ])
      end
    end

    private

    # Stacked circle + label; custom button — `sui.button` is horizontal flex
    # and doesn't fit the 3-col grid.
    def theme_swatch_button(theme)
      button_tag(
        type: "button",
        "aria-label": theme[:label],
        title: theme[:label],
        class: self.class.style.swatch_button,
        data: {
          action: "click->shadcnrb--theme-switcher--component#setTheme",
          theme: theme[:key]
        }
      ) do
        swatch_class = Shadcnrb::TailwindMerge.call("size-5 rounded-full", theme[:swatch])
        safe_join([
          tag.span("", class: swatch_class),
          tag.span(theme[:label])
        ])
      end
    end

    def mode_button(mode_key, label)
      button_tag(
        type: "button",
        "aria-label": label,
        class: self.class.style.mode_button,
        data: { action: "click->shadcnrb--theme-switcher--component#setMode", mode: mode_key }
      ) do
        label
      end
    end
  end
end
