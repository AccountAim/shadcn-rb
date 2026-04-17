<p align="center">
  <img src="./assets/logo.svg" alt="shadcn-rb" width="80" height="80">
</p>

# shadcn-rb

[shadcn/ui](https://ui.shadcn.com) components for Rails, exposed as an
ActionView builder. Plain Ruby modules mix into a Builder object accessible as
`sui` in any ERB/Slim view.

Real Rails helpers (`link_to`, `button_to`, `form_with`) work underneath, so
CSRF, Turbo, route helpers, and `current_page?` all behave exactly as you'd
expect.

Where this port intentionally differs from shadcn/ui (element choices, scope,
Stimulus vs Radix), see [DIVERGENCES.md](./DIVERGENCES.md).

## Quick start

```ruby
# Gemfile
group :development do
  gem "shadcn-rb", github: "accountaim/shadcn-rb"
end
```

shadcnrb is a build-time tool, not a runtime dependency — see [How it works](#how-it-works).

```bash
bundle install
bin/rails g shadcnrb:install
bin/rails g shadcnrb:component button
bin/rails g shadcnrb:component dialog
```

In any view:

```erb
<%= sui.button "Save", variant: :default %>
<%= sui.button_to "Delete", record_path(r), method: :delete, variant: :destructive, data: { turbo_confirm: "Sure?" } %>
<%= sui.link_to "Edit", edit_record_path(r), variant: :outline %>
```

## How it works

Same "eject" model as [shadcn/ui](https://ui.shadcn.com): the gem ships no
runtime code. Generators copy every file into
`app/components/shadcnrb/`; after install, the gem is only needed to re-run
them — which is why it lives in the `:development` group.

`sui` is an ActionView helper (mixed in via the shadcnrb initializer) that
builds a `Shadcnrb::Builder` per request. The Builder delegates missing
methods to the view context, so `link_to`, `button_to`, `form_with`, path
helpers, Turbo, and CSRF work underneath without any proxying — component
methods only compute classes + data attributes and hand off to the real
Rails primitive.

## Installing components

```bash
bin/rails g shadcnrb:component <name>    # one at a time
bin/rails g shadcnrb:components           # every component at once
```

Dependencies between components resolve automatically. A few need extra gems
(`codeblock` → `rouge`) — add them yourself if you pull them in.

## Live docs

Live API docs for every component, plus all the cross-cutting topics, are on
the example site — **[shadcnrb.accountaim.io/docs](https://shadcnrb.accountaim.io/docs)**:

- [Installation](https://shadcnrb.accountaim.io/docs/installation) — what the installer writes, the complete directory layout, step-by-step wiring.
- [Styles](https://shadcnrb.accountaim.io/docs/styles) — `Shadcnrb::Style.apply(:name)` / `Shadcnrb::Style.reset`; reference `Neobrutalism` implementation.
- [Themes & dark mode](https://shadcnrb.accountaim.io/docs/themes) — preset palettes, `.dark`, `sui.theme_switcher`, adding your own.
- [Overriding a component](https://shadcnrb.accountaim.io/docs/overriding) — adding variants, rewriting markup, when to reach for a style instead.
- [Icon](https://shadcnrb.accountaim.io/docs/components/icon), [Toast](https://shadcnrb.accountaim.io/docs/components/toast), [Sidebar](https://shadcnrb.accountaim.io/docs/components/sidebar), [Dialog](https://shadcnrb.accountaim.io/docs/components/dialog) / [Drawer](https://shadcnrb.accountaim.io/docs/components/drawer), and every other component.

## Requirements

- Ruby ≥ 3.2
- Rails ≥ 7.1
- Tailwind CSS v4
- importmap-rails (default Rails 8)

## Credits

- [shadcn/ui](https://ui.shadcn.com) — the original component designs,
  Tailwind classes, and oklch theme tokens this gem ports to Rails.
- [ruby-ui](https://github.com/ruby-ui/ruby-ui) — prior-art Ruby port that
  inspired the approach; shadcnrb uses ActionView tag helpers instead of
  Phlex.

## License

MIT — see [LICENSE](LICENSE) for the full notice and upstream attributions.
