# frozen_string_literal: true

# shadcn divergence: Stimulus `shadcnrb--dropdown-menu--component` controller replaces
# Radix `DropdownMenuPrimitive`. Checkbox-item / radio-item variants omitted;
# see DIVERGENCES.md. Sub-menus are supported via `m.sub` → `:dropdown_menu_sub`
# scope (hover-open, cascading close) that inherits most methods from the
# top-level via `method_prefix: "sub_"`. upstream: dropdown-menu.tsx.
#
# shadcn divergence: child parts (`trigger`, `content`, `item`, `group`, `label`,
# `separator`, `shortcut`, `sub`) are orphan-protected — they only render when
# called through a `:dropdown_menu` (or `:dropdown_menu_sub`) `Shadcnrb::Scope`
# yielded by `sui.dropdown_menu do |m| ... end`. Block-form methods (`content`,
# `group`, `item`, `sub.content`) yield a child scope so user-block helpers
# like `i.link_to` / `i.button_to` get scope-aware defaults (e.g.
# `variant: :bare`) without callers writing the variant explicitly.

module Shadcnrb
  class DropdownMenu < Component
    def dropdown_menu(**opts, &block)
      opts[:data] = (opts[:data] || {}).merge(
        slot: "dropdown-menu",
        controller: [ "shadcnrb--dropdown-menu--component", opts.dig(:data, :controller) ].compact.join(" ")
      )
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
      scope = Scope.new(@builder, kind: :dropdown_menu, component: self)
      content_tag(:div, **opts) do
        block ? capture(scope, &block) : "".html_safe
      end
    end

    def trigger(name = nil, variant: :default, size: :default, scope: nil, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(
        slot: "dropdown-menu-trigger",
        action: "click->shadcnrb--dropdown-menu--component#toggle"
      )
      button(name, variant:, size:, **opts, &block)
    end

    def content(scope: nil, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(
        slot: "dropdown-menu-content",
        "shadcnrb--dropdown-menu--component-target": "content",
        state: "closed"
      )
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.content, opts[:class])
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def group(scope: nil, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(slot: "dropdown-menu-group", role: "group")
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.group, opts[:class])
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def label(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.label, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "dropdown-menu-label")
      content_tag(:div, **opts) do
        block ? capture(&block) : name.to_s
      end
    end

    def separator(scope: nil, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.separator, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "dropdown-menu-separator")
      content_tag(:div, "", **opts)
    end

    # Right-aligned keyboard-shortcut label inside an item.
    #   m.item("Save") { m.shortcut "⌘S" }
    def shortcut(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.shortcut, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "dropdown-menu-shortcut")
      tag.span(**opts) { block ? capture(&block) : name.to_s }
    end

    # Five shapes:
    #
    #   # GET path — renders `<a>` via Rails link_to (path helpers, Turbo, etc.).
    #   m.item "Profile", profile_path
    #
    #   # Non-GET path — real POST/PUT/DELETE form via button_to (CSRF-safe).
    #   m.item "Sign out", logout_path, method: :delete
    #
    #   # Text-only shortcut — bare `<button>`.
    #   m.item "Save"
    #
    #   # Block (scope) — yields a child scope; helpers inside it default
    #   # `variant: :bare` so they sit cleanly in the row.
    #   m.item do |i|
    #     i.link_to "Profile", profile_path
    #   end
    def item(name = nil, options = nil, method: nil, icon: nil, scope: nil, **opts, &block)
      options ||= opts.delete(:href)
      # `closeAll` cascades up through parent dropdowns so picking an item
      # inside a sub-menu also closes the outer menu (Radix behaviour).
      close_action = "click->shadcnrb--dropdown-menu--component#closeAll"
      opts[:data] = (opts[:data] || {}).merge(
        slot: "dropdown-menu-item",
        action: merge_action(opts[:data], close_action)
      )
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.item, opts[:class])
      opts[:role] ||= "menuitem"

      # Internal calls go through a child scope so `link_to` / `button_to`
      # see `scope:` and auto-default to `:bare` — same mechanism as a
      # user block writing `m.item do |i| i.link_to ... end`.
      slot = scope.child_scope

      if method
        # CSRF-safe form for non-GET methods. Block form passes the URL as
        # `options` (with `name: nil`) so the wrapper's `content_with_icon`
        # doesn't prepend the path as text.
        if block
          slot.button_to(nil, name, method:, **opts, &block)
        else
          slot.button_to(name, options, method:, **opts)
        end
      elsif block
        # User-content block: yield a child scope so `i.link_to` etc.
        # auto-default to `:bare`.
        content_tag(:div, **opts) { scope.capture_block(&block) }
      elsif options
        slot.link_to(name, options, icon:, **opts)
      else
        opts[:type] ||= "button"
        button_tag(**opts) { content_with_icon(name, icon:) }
      end
    end

    # Cascading sub-menu. Each sub spawns its own nested Stimulus controller
    # so hover / close timers are scoped to that level — nesting Just Works.
    #
    #   m.item "New file"
    #   m.sub do |sub|
    #     sub.trigger "Share"
    #     sub.content do
    #       m.item "Email",  "#"
    #       m.item "Slack",  "#"
    #     end
    #   end
    def sub(scope: nil, &block)
      sub_scope = Scope.new(@builder, kind: :dropdown_menu_sub, component: self,
        method_prefix: "sub_", parent: scope)
      content_tag(:div,
        class: "relative",
        data: {
          slot: "dropdown-menu-sub",
          controller: "shadcnrb--dropdown-menu--component"
        }) do
        block ? capture(sub_scope, &block) : "".html_safe
      end
    end

    # Right-anchored sub-menu trigger (different styling + hover wiring than
    # the top-level `trigger`).
    def sub_trigger(name = nil, icon: nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.sub_trigger, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(
        slot: "dropdown-menu-sub-trigger",
        action: merge_action(opts[:data],
          "mouseenter->shadcnrb--dropdown-menu--component#openOnHover",
          "focus->shadcnrb--dropdown-menu--component#openOnHover",
          "mouseleave->shadcnrb--dropdown-menu--component#scheduleClose",
          "click->shadcnrb--dropdown-menu--component#toggle"),
        state: "closed"
      )
      opts[:type] ||= "button"
      opts[:role] ||= "menuitem"
      opts[:"aria-haspopup"] ||= "menu"
      opts[:"aria-expanded"] ||= "false"
      button_tag(**opts) do
        label = content_with_icon(name, icon:, &block)
        safe_join([ label, self.icon(:"chevron-right", class: "ml-auto size-4 opacity-60") ])
      end
    end

    # Right-anchored sub-menu content panel.
    def sub_content(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.sub_content, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(
        slot: "dropdown-menu-sub-content",
        "shadcnrb--dropdown-menu--component-target": "content",
        action: merge_action(opts[:data],
          "mouseenter->shadcnrb--dropdown-menu--component#cancelClose",
          "mouseleave->shadcnrb--dropdown-menu--component#scheduleClose"),
        state: "closed"
      )
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    private :trigger, :content, :sub, :group, :label, :separator, :shortcut,
            :item, :sub_trigger, :sub_content
  end
end
