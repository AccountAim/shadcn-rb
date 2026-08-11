# frozen_string_literal: true

# shadcn divergence: child parts (`item`, `link`, `trigger`, `content`) are
# orphan-protected — they only render when called through a `:navigation_menu`-kind
# `Shadcnrb::Scope` (yielded by `sui.navigation_menu do |nav| ... end`, or via
# `sui.navigation_menu_proxy`).
#
# shadcn divergence: no floating-ui. Panels are `popover="manual"` elements
# shown in the top layer and positioned by the shared anchored engine, which
# the controller subclasses. See anchored/component_controller.js.

module Shadcnrb
  # A simple horizontal navigation menu — the structural pieces of shadcn's
  # Radix Navigation Menu without the dropdown/viewport complexity. For
  # dropdowns inside a nav item, compose with `dropdown_menu`.
  class NavigationMenu < Component
    include Shadcnrb::Anchored::Component

    def navigation_menu(**opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
      opts[:data]  = (opts[:data] || {}).merge(
        slot: "navigation-menu",
        controller: [ "shadcnrb--navigation-menu--component", opts.dig(:data, :controller) ].compact.join(" "),
        action: merge_action(opts[:data],
          "keydown.esc@window->shadcnrb--navigation-menu--component#dismiss"),
        "shadcnrb--navigation-menu--component-open-value": ""
      )
      opts[:"aria-label"] ||= "Main"
      scope = Scope.new(@builder, kind: :navigation_menu, component: self)
      content_tag(:nav, **opts) do
        content_tag(:ul, class: self.class.style.list, data: { slot: "navigation-menu-list" }) do
          block ? capture(scope, &block) : "".html_safe
        end
      end
    end

    def proxy
      Scope.new(@builder, kind: :navigation_menu, component: self)
    end

    # Plain item: the block is the row (`nav.item { nav.link "Home", "/" } `).
    # With a `nav.trigger` inside, the same slot shape as every other overlay
    # applies — the trigger is the tab, the rest of the block is the dropdown
    # panel:
    #
    #   nav.item do
    #     nav.trigger "Products"
    #     ...panel body...
    #   end
    #
    # `content:` is the panel's own option hash.
    def item(content: {}, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.item, opts[:class])
      opts[:data]  = (opts[:data] || {}).merge(slot: "navigation-menu-item")
      content_tag(:li, **opts) do
        trigger_html, body = capture_parts(scope, &block)
        if @nav_value
          value, @nav_value = @nav_value, nil
          safe_join([ trigger_html, panel(body, value:, **content) ])
        else
          body
        end
      end
    end

    # Active state: pass `active: true` explicitly, or let it auto-detect via
    # `current_page?` when `options` is a Rails path.
    #
    # Shortcut form renders `<a>`. Block form renders a wrapper `<div>` —
    # consumer supplies the interactive element (link_to / button_to) and
    # inherits the styling.
    def link(name = nil, options = nil, active: nil, icon: nil, scope: nil, **opts, &block)
      active = safe_current_page?(options) if active.nil?
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.link, opts[:class])
      opts[:data]  = (opts[:data] || {}).merge(slot: "navigation-menu-link", active: active.to_s)
      if block
        content_tag(:div, **opts) { scope.capture_block(&block) }
      else
        scope.child_scope.link_to(name, options, icon:, **opts)
      end
    end

    # The tab that opens an item's panel — a styled part rendered by the menu
    # itself (like dropdown's `sub.trigger`), stashed like a slot so it can
    # sit anywhere in the item block. Opens on mouseenter/focus, toggles on
    # click; a 150ms close delay lets the pointer travel from trigger to
    # panel. The trigger/panel pairing is structural — both live in the same
    # `nav.item` — so the shared value is minted here, not by the caller.
    def trigger(name = nil, scope: nil, **opts, &block)
      @nav_value = "nav-#{@nav_uid = (@nav_uid || 0) + 1}"
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.trigger, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(
        slot: "navigation-menu-trigger",
        "shadcnrb--navigation-menu--component-target": "trigger",
        "nav-value": @nav_value,
        action: merge_action(opts[:data],
          "mouseenter->shadcnrb--navigation-menu--component#open",
          "focus->shadcnrb--navigation-menu--component#open",
          "mouseleave->shadcnrb--navigation-menu--component#close",
          "click->shadcnrb--navigation-menu--component#toggle"),
        state: "closed"
      )
      opts[:type] ||= "button"
      opts[:"aria-expanded"] ||= "false"
      opts[:"aria-haspopup"] ||= "menu"
      @trigger_html = button_tag(**opts) do
        content_with_icon(name, &block)
      end
      "".html_safe
    end

    # Panel for the trigger minted in the same item, placed below it in the
    # top layer; kept open while the pointer is inside it.
    def panel(body, value:, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.content, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(
        "nav-value": value,
        action: merge_action(opts[:data],
          "mouseenter->shadcnrb--navigation-menu--component#cancelClose",
          "mouseleave->shadcnrb--navigation-menu--component#close")
      )
      opts = anchored_panel(opts, slot: "navigation-menu-content", side: :bottom, align: :start,
        controller: "shadcnrb--navigation-menu--component")
      content_tag(:div, body, **opts)
    end

    private :item, :link, :trigger, :panel
  end
end
