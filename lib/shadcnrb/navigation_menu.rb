# frozen_string_literal: true

# shadcn divergence: child parts (`item`, `link`, `trigger`, `content`) are
# orphan-protected — they only render when called through a `:navigation_menu`-kind
# `Shadcnrb::Scope` (yielded by `sui.navigation_menu do |nav| ... end`, or via
# `sui.navigation_menu_proxy`).

module Shadcnrb
  # A simple horizontal navigation menu — the structural pieces of shadcn's
  # Radix Navigation Menu without the dropdown/viewport complexity. For
  # dropdowns inside a nav item, compose with `dropdown_menu`.
  class NavigationMenu < Component
    def navigation_menu(**opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
      opts[:data]  = (opts[:data] || {}).merge(
        slot: "navigation-menu",
        controller: [ "shadcnrb--navigation-menu--component", opts.dig(:data, :controller) ].compact.join(" "),
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

    def item(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.item, opts[:class])
      opts[:data]  = (opts[:data] || {}).merge(slot: "navigation-menu-item")
      content_tag(:li, **opts) { scope.capture_block(&block) }
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

    # Hover-triggered dropdown trigger. Pair with `content(value: "same")`
    # inside the same `item`. Opens on mouseenter/focus, toggles on click;
    # a 150ms close delay lets the pointer travel from trigger to content.
    #
    #   nav.item do
    #     nav.trigger "Products", value: "products"
    #     nav.content value: "products" do
    #       ...
    #     end
    #   end
    def trigger(name = nil, value:, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.trigger, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(
        slot: "navigation-menu-trigger",
        "shadcnrb--navigation-menu--component-target": "trigger",
        "nav-value": value.to_s,
        action: merge_action(opts[:data],
          "mouseenter->shadcnrb--navigation-menu--component#open",
          "focus->shadcnrb--navigation-menu--component#open",
          "mouseleave->shadcnrb--navigation-menu--component#scheduleClose",
          "click->shadcnrb--navigation-menu--component#toggle"),
        state: "closed"
      )
      opts[:type] ||= "button"
      opts[:"aria-expanded"] ||= "false"
      opts[:"aria-haspopup"] ||= "menu"
      button_tag(**opts) do
        content_with_icon(name, &block)
      end
    end

    # Content panel for a `trigger` with matching `value`. Absolute-positioned
    # below the trigger; kept open while the pointer is inside it.
    def content(value:, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.content, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(
        slot: "navigation-menu-content",
        "shadcnrb--navigation-menu--component-target": "content",
        "nav-value": value.to_s,
        action: merge_action(opts[:data],
          "mouseenter->shadcnrb--navigation-menu--component#cancelClose",
          "mouseleave->shadcnrb--navigation-menu--component#scheduleClose"),
        state: "closed"
      )
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    private :item, :link, :trigger, :content
  end
end
