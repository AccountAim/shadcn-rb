# frozen_string_literal: true

# shadcn divergence: Stimulus `shadcnrb--dialog--component` controller replaces Radix
# `DialogPrimitive.Root`; CSS opacity/scale transitions replace Radix animation
# states. Lazy-loading via `src:` uses Turbo Frames instead of React children.
# upstream: dialog.tsx.
#
# shadcn divergence: no portal. Backdrop and panel are `popover="manual"`
# elements the controller shows in the top layer, so no ancestor transform,
# filter or overflow can box them in. See dialog/component_controller.js.
#
# shadcn divergence: child parts (`header`, `title`, `close`, ...) are
# orphan-protected — they're private on the Dialog class and reachable only
# through a `:dialog` `Shadcnrb::Scope` (yielded by `sui.dialog do |d| ... end`
# or via `sui.dialog_proxy`). Calling `sui.dialog_trigger` raises
# NoMethodError.
#
# `Drawer` subclasses this: same markup, controller and parts under the
# `drawer` slot name, with an edge-anchored panel instead of a centred one.

module Shadcnrb
  class Dialog < Component
    include Shadcnrb::Anchored::TriggerSlot

    # The block is the dialog panel; `d.trigger` names what opens it — the
    # same slot shape as tooltip / dropdown_menu. Click lives on the root
    # (clicks inside the panel or backdrop are filtered out by the
    # controller), so the trigger markup is used verbatim. A dialog rendered
    # already open (server-driven confirmations) simply has no trigger.
    #
    #   sui.dialog do |d|
    #     d.trigger { sui.button "Edit profile", variant: :outline }
    #     d.header do
    #       d.title "Edit profile"
    #       d.description "Update your display name."
    #     end
    #     d.footer { d.close "Save" }
    #   end
    #
    # Pass `src:` to lazy-load the panel via a Turbo Frame when the dialog
    # opens — the block body becomes the loading state (`loading:` sets it
    # when there's no block, e.g. the `dialog:` kwarg form). `reload: true`
    # re-fetches on every open instead of caching the first load. `**opts`
    # land on the root; `content:` is the panel's own option hash.
    def dialog(open: false, src: nil, reload: false, loading: nil, content: {}, **opts, &block)
      modal(self.class.style.content, open:, src:, reload:, loading:, content:, **opts, &block)
    end

    # Bare scope for lazy-loaded partials rendered outside a `sui.dialog`
    # block (turbo-frame content).
    def proxy
      Scope.new(@builder, kind: slot.to_sym, component: self)
    end

    private

    # Prefix for `data-slot`, the controller identifier and the detached
    # trigger attribute (`data-dialog="id"`).
    def slot = "dialog"

    def controller = "shadcnrb--#{slot}--component"

    def modal(panel_class, open:, src:, reload:, loading:, content:, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(
        slot:,
        controller: [ controller, opts.dig(:data, :controller) ].compact.join(" "),
        action: merge_action(opts[:data],
          "click->#{controller}#open",
          "keydown.esc@window->#{controller}#close"),
        "#{controller}-open-value": open,
        "#{controller}-close-delay-value": self.class.style.close_delay
      )
      content_tag(:div, **opts) do
        trigger_html, body = capture_parts(proxy, &block)
        safe_join([ trigger_html, backdrop,
                    panel(body, panel_class, src:, reload:, loading:, **content) ])
      end
    end

    def backdrop
      tag.div("",
        popover: "manual",
        data: { slot: "#{slot}-overlay", "#{controller}-target": "backdrop",
                action: "click->#{controller}#close" },
        class: self.class.style.backdrop
      )
    end

    def panel(body, panel_class, src:, reload:, loading:, **opts)
      opts[:popover] = "manual"
      opts[:data] =
        (opts[:data] || {}).merge(slot: "#{slot}-content", "#{controller}-target": "content")
      opts[:class] = Shadcnrb::TailwindMerge.call(panel_class, opts[:class])

      content_tag(:div, **opts) do
        body = lazy_frame(body, src:, reload:, loading:, slot:) if src

        close_btn = button(
          variant: :ghost,
          size: :"icon-sm",
          "aria-label": "Close",
          class: self.class.style.close_btn_pos,
          data: { slot: "#{slot}-close", action: "click->#{controller}#close" }
        ) { icon(:x) }
        safe_join([ body, close_btn ])
      end
    end

    def header(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.header, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "#{slot}-header")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def footer(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.footer, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "#{slot}-footer")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def title(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.title, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "#{slot}-title")
      content_tag(:h2, **opts) do
        block ? capture(&block) : name.to_s
      end
    end

    def description(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.description, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "#{slot}-description")
      content_tag(:p, **opts) do
        block ? capture(&block) : name.to_s
      end
    end

    # Wraps a button (or any content) so clicking it closes the dialog.
    # Usage: d.close { sui.button "Cancel", variant: :outline }
    def close(name = nil, scope: nil, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(slot: "#{slot}-close",
        action: "click->#{controller}#close")
      if block
        content_tag(:span, **opts) { scope.capture_block(&block) }
      else
        button(name, **opts)
      end
    end
  end
end
