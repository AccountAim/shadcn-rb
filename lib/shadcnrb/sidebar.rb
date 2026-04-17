# frozen_string_literal: true

# shadcn divergence: Stimulus controller replaces Radix `SidebarProvider` +
# `useSidebar` hook; offcanvas mode uses CSS transforms + media queries instead
# of Radix Sheet. Inline init script in `sidebar_wrapper` handles pre-paint
# state restore. upstream: sidebar.tsx.
#
# shadcn divergence: child parts (`sidebar`, `trigger`, `inset`, `header`,
# `menu`, ...) are orphan-protected — they only render when called through a
# `:sidebar`-kind `Shadcnrb::Scope` (yielded by
# `sui.sidebar_wrapper do |s| ... end`, or via `sui.sidebar_proxy` for standalone
# demos). Flat names, one scope — inner parts don't yield nested scopes
# because the nesting is visual, not scoping.

module Shadcnrb
  class Sidebar < Component
    WIDTH      = "16rem"
    WIDTH_ICON = "3rem"

    SIDEBAR_INIT_SCRIPT = <<~JS.freeze
      (function(){var w=document.currentScript.parentElement;var d=w.querySelector('[data-shadcnrb--sidebar--component-target=detector]');var desktop=d&&getComputedStyle(d).display!=='none';var i=w.querySelector('[data-slot=sidebar]');var c=w.querySelector('[data-slot=sidebar-container]');var cfg=(i&&i.dataset.configuredCollapsible)||'offcanvas';var s,m;if(desktop){s=localStorage.getItem('sidebar-state')==='collapsed'?'collapsed':'expanded';m=cfg;}else{s='collapsed';m='offcanvas';}if(c)c.style.transition='none';w.dataset.state=s;if(i){i.dataset.state=s;i.dataset.collapsible=s==='collapsed'?m:'';}if(c){void c.offsetHeight;requestAnimationFrame(function(){c.style.transition='';});}})();
    JS

    # `bounded: true` for demo/preview cards — swaps the default `h-svh`
    # viewport height for `h-full` and creates a containing block (via
    # transform) so the sidebar's `position:fixed` container snaps to the
    # parent instead of the viewport.
    def sidebar_wrapper(bounded: false, **opts, &block)
      wrapper_class = self.class.style.wrapper
      if bounded
        wrapper_class = Shadcnrb::TailwindMerge.call(
          wrapper_class,
          "!h-full [transform:translateZ(0)] [&_[data-slot=sidebar-container]]:!h-full"
        )
      end
      opts[:class] = Shadcnrb::TailwindMerge.call(wrapper_class, opts[:class])
      opts[:style] = "--sidebar-width: #{WIDTH}; --sidebar-width-icon: #{WIDTH_ICON};"
      opts[:data] = (opts[:data] || {}).merge(
        slot: "sidebar-wrapper",
        controller: "shadcnrb--sidebar--component",
        state: "expanded",
        collapsible: "offcanvas"
      )
      # shadcn divergence: kind is `:sidebar` (not `:sidebar_wrapper`) so
      # `s.menu_item` routes to `menu_item` — the flat naming the child
      # methods already use.
      scope = Scope.new(@builder, kind: :sidebar, component: self)
      content_tag(:div, **opts) do
        detector = tag.span("",
          class: "hidden md:block",
          data: { "shadcnrb--sidebar--component-target": "detector" })
        backdrop = tag.div("",
          class: self.class.style.mobile_backdrop,
          data: { action: "click->shadcnrb--sidebar--component#toggle" })
        body = block ? capture(scope, &block) : "".html_safe
        init = javascript_tag(SIDEBAR_INIT_SCRIPT)
        safe_join([ detector, backdrop, body, init ])
      end
    end

    # Returns a bare `:sidebar` scope for rendering individual parts outside
    # a `sui.sidebar_wrapper` block — docs demos that want to show a single
    # `menu_button` or `separator` in isolation. Pieces that depend on the
    # Stimulus controller (`trigger`, `rail`) are functionally dead without
    # the wrapper ancestor.
    def proxy
      Scope.new(@builder, kind: :sidebar, component: self)
    end

    # --- Wrapper-scoped parts (siblings of the inner `sidebar`) -------------

    def sidebar(side: :left, variant: :sidebar, collapsible: :offcanvas, scope: nil, **opts, &block)
      side = side.to_sym
      variant = variant.to_sym
      collapsible = collapsible.to_sym
      style = self.class.style

      if collapsible == :none
        opts[:class] = Shadcnrb::TailwindMerge.call(style.root_none, opts[:class])
        opts[:data] = (opts[:data] || {}).merge(slot: "sidebar")
        return content_tag(:div, **opts) { scope.capture_block(&block) }
      end

      floating_or_inset = (variant == :floating || variant == :inset)

      gap_class = Shadcnrb::TailwindMerge.call(
        style.root_gap_base,
        floating_or_inset ? style.root_gap_icon_floating : style.root_gap_icon_default
      )

      container_class = Shadcnrb::TailwindMerge.call(
        style.root_container_base,
        side == :left ? style.root_container_left : style.root_container_right,
        floating_or_inset ? style.root_container_icon_floating :
                            style.root_container_icon_default,
        opts.delete(:class)
      )

      outer_data = {
        state: "expanded",
        collapsible: "",
        "configured-collapsible": collapsible,
        variant:,
        side:,
        slot: "sidebar"
      }.merge(opts.delete(:data) || {})

      content_tag(:div, class: style.root_outer, data: outer_data, **opts) do
        gap_div = tag.div("", class: gap_class, data: { slot: "sidebar-gap" })
        container_div = content_tag(:div, class: container_class,
          data: { slot: "sidebar-container" }) do
          content_tag(:div, class: style.root_inner,
            data: { sidebar: "sidebar", slot: "sidebar-inner" }) do
            block ? capture(&block) : "".html_safe
          end
        end
        safe_join([ gap_div, container_div ])
      end
    end

    def trigger(scope: nil, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.trigger, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-trigger",
        action: "click->shadcnrb--sidebar--component#toggle")
      opts[:type] ||= "button"
      button_tag(**opts) { icon(:"panel-left") }
    end

    def rail(scope: nil, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.rail, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-rail",
        action: "click->shadcnrb--sidebar--component#toggle")
      opts[:tabindex] = "-1"
      opts[:"aria-label"] = "Toggle Sidebar"
      opts[:type] ||= "button"
      button_tag("", **opts)
    end

    def inset(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.inset, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-inset")
      content_tag(:main, **opts) { scope.capture_block(&block) }
    end

    def inset_header(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.inset_header, opts[:class])
      content_tag(:header, **opts) { scope.capture_block(&block) }
    end

    def inset_content(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.inset_content, opts[:class])
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    # --- Sidebar-internal parts --------------------------------------------

    def header(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.header, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-header")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def footer(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.footer, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-footer")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def content(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.content, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-content")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def group(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.group, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-group")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    # `collapsible: true` renders as a `<button>` that toggles a surrounding
    # `collapsible` wrapper — composable pattern for whole-group expand/collapse.
    def group_label(name = nil, collapsible: false, scope: nil, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-group-label")

      if collapsible
        opts[:class] = Shadcnrb::TailwindMerge.call(
          self.class.style.group_label,
          "w-full cursor-pointer hover:bg-sidebar-accent hover:text-sidebar-accent-foreground",
          opts[:class]
        )
        opts[:data] = opts[:data].merge(
          action: merge_action(opts[:data], "click->shadcnrb--collapsible--component#toggle")
        )
        opts[:type] ||= "button"
        return button_tag(**opts) { content_with_icon(name, &block) }
      end

      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.group_label, opts[:class])
      content_tag(:div, **opts) { content_with_icon(name, &block) }
    end

    def group_action(scope: nil, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-group-action")
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.group_action, opts[:class])
      if (href = opts.delete(:href))
        scope.child_scope.link_to(nil, href, **opts, &block)
      else
        opts[:type] ||= "button"
        button_tag(**opts, &block)
      end
    end

    def group_content(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.group_content, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-group-content")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def menu(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.menu, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-menu")
      content_tag(:ul, **opts) { scope.capture_block(&block) }
    end

    def menu_item(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.menu_item, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-menu-item")
      content_tag(:li, **opts) { scope.capture_block(&block) }
    end

    # Shortcut:         s.menu_button "Dashboard", root_path
    # Block:            s.menu_button active: … do …
    # Collapsible:      s.menu_button collapsible: true, ... do …
    #                   → trigger inside a surrounding `collapsible` wrapper.
    # Dropdown trigger: s.menu_button dropdown_trigger: true, ... do …
    #                   → trigger inside a surrounding `dropdown_menu` wrapper.
    def menu_button(name = nil, options = nil, active: nil, size: :default,
                    variant: :default, tooltip: nil, collapsible: false,
                    dropdown_trigger: false, icon: nil, scope: nil, **html_opts, &block)
      active = safe_current_page?(options) if active.nil? && options
      size = size.to_sym
      variant = variant.to_sym
      style = self.class.style

      size_class = case size
      when :sm then style.menu_button_size_sm
      when :lg then style.menu_button_size_lg
      else          style.menu_button_size_default
      end

      variant_class = variant == :outline ? style.menu_button_variant_outline :
                                            style.menu_button_variant_default

      html_opts[:class] = Shadcnrb::TailwindMerge.call(
        style.menu_button_base,
        variant_class,
        size_class,
        active ? style.menu_button_active : style.menu_button_inactive,
        html_opts[:class]
      )
      html_opts[:data] = (html_opts[:data] || {}).merge(
        slot: "sidebar-menu-button",
        sidebar: "menu-button",
        size:,
        active: !!active
      )
      html_opts[:"aria-current"] = "page" if active
      html_opts[:aria] = (html_opts[:aria] || {}).merge(current: "page") if active
      if tooltip
        html_opts[:data][:tooltip] = tooltip
        html_opts[:title] = tooltip
      end

      if collapsible
        html_opts[:data] = html_opts[:data].merge(
          action: merge_action(html_opts[:data], "click->shadcnrb--collapsible--component#toggle")
        )
        html_opts[:type] ||= "button"
        button_tag(**html_opts) { content_with_icon(name, icon:, &block) }
      elsif dropdown_trigger
        html_opts[:data] = html_opts[:data].merge(
          slot: "dropdown-menu-trigger",
          action: merge_action(html_opts[:data], "click->shadcnrb--dropdown-menu--component#toggle")
        )
        html_opts[:type] ||= "button"
        button_tag(**html_opts) { content_with_icon(name, icon:, &block) }
      elsif block
        content_tag(:div, **html_opts) { scope.capture_block(&block) }
      else
        scope.child_scope.link_to(name, options || "#", icon:, **html_opts)
      end
    end

    def menu_action(show_on_hover: false, scope: nil, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-menu-action")
      style = self.class.style
      cls = style.menu_action_base
      cls = Shadcnrb::TailwindMerge.call(cls, style.menu_action_show_on_hover) if show_on_hover
      opts[:class] = Shadcnrb::TailwindMerge.call(cls, opts[:class])
      opts[:type] ||= "button"
      button_tag(**opts, &block)
    end

    def menu_badge(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.menu_badge, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-menu-badge")
      content_tag(:div, **opts) do
        block ? capture(&block) : name.to_s
      end
    end

    def menu_skeleton(show_icon: false, scope: nil, **opts)
      style = self.class.style
      opts[:class] = Shadcnrb::TailwindMerge.call(style.menu_skeleton, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-menu-skeleton")
      width = rand(50..90)
      content_tag(:div, **opts) do
        parts = []
        parts << tag.span("", class: style.menu_skeleton_icon) if show_icon
        parts << tag.span("",
          class: "#{style.menu_skeleton_text} max-w-[var(--skeleton-width)]",
          style: "--skeleton-width: #{width}%"
        )
        safe_join(parts)
      end
    end

    def menu_sub(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.menu_sub, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-menu-sub")
      content_tag(:ul, **opts) { scope.capture_block(&block) }
    end

    def menu_sub_item(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.menu_sub_item, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-menu-sub-item")
      content_tag(:li, **opts) { scope.capture_block(&block) }
    end

    # Same shortcut/block shape as `menu_button`.
    def menu_sub_button(name = nil, options = nil, active: nil, size: :md, scope: nil, **html_opts, &block)
      active = safe_current_page?(options) if active.nil? && options
      size = size.to_sym
      style = self.class.style

      size_class = size == :sm ? style.menu_sub_button_size_sm : style.menu_sub_button_size_md

      html_opts[:class] = Shadcnrb::TailwindMerge.call(
        style.menu_sub_button_base,
        size_class,
        html_opts[:class]
      )
      html_opts[:data] = (html_opts[:data] || {}).merge(
        slot: "sidebar-menu-sub-button",
        size:,
        active: !!active
      )

      if block
        content_tag(:div, **html_opts) { scope.capture_block(&block) }
      else
        scope.child_scope.link_to(name, options || "#", **html_opts)
      end
    end

    def separator(scope: nil, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.separator, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-separator")
      tag.hr(**opts)
    end

    def sidebar_input(scope: nil, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call("h-8 w-full bg-background shadow-none",
        opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "sidebar-input")
      input(**opts)
    end

    private :sidebar, :trigger, :rail, :inset, :inset_header, :inset_content,
            :header, :footer, :content, :group, :group_label, :group_action,
            :group_content, :menu, :menu_item, :menu_button, :menu_action,
            :menu_badge, :menu_skeleton, :menu_sub, :menu_sub_item,
            :menu_sub_button, :separator, :sidebar_input
  end
end
