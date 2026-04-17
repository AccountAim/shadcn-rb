# frozen_string_literal: true

# shadcn divergence: Stimulus `shadcnrb--dialog--component` controller replaces Radix
# `DialogPrimitive.Root`; CSS opacity/scale transitions replace Radix animation
# states. Lazy-loading via `src:` uses Turbo Frames instead of React children.
# upstream: dialog.tsx.
#
# shadcn divergence: child parts (`trigger`, `content`, `header`, `title`,
# `close`, ...) are orphan-protected — they're private on the Dialog class
# and reachable only through a `:dialog` `Shadcnrb::Scope` (yielded by
# `sui.dialog do |d| ... end` or via `sui.dialog_proxy`). Calling
# `sui.dialog_trigger` raises NoMethodError.

module Shadcnrb
  class Dialog < Component
    def dialog(open: false, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(
        slot: "dialog",
        controller: "shadcnrb--dialog--component",
        "shadcnrb--dialog--component-open-value": open
      )
      content_tag(:div, **opts) do
        block ? capture(proxy, &block) : "".html_safe
      end
    end

    # Bare scope for lazy-loaded partials rendered outside a `sui.dialog`
    # block (turbo-frame content).
    def proxy
      Scope.new(@builder, kind: :dialog, component: self)
    end

    def trigger(name = nil, variant: :default, size: :default, scope: nil, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(
        slot: "dialog-trigger",
        action: "click->shadcnrb--dialog--component#open"
      )
      button(name, variant:, size:, **opts, &block)
    end

    # Renders the dialog panel (backdrop + content). Pass `src:` to lazy-load
    # content via a Turbo Frame when the dialog opens:
    #
    #   d.content(src: edit_profile_path) do
    #     tag.p "Loading...", class: "text-sm text-muted-foreground animate-pulse"
    #   end
    #
    # Pass `reload: true` to re-fetch content every time the dialog opens
    # (instead of caching the first load):
    #
    #   d.content(src: edit_profile_path, reload: true)
    def content(src: nil, reload: false, scope: nil, **opts, &block)
      style = self.class.style
      backdrop = tag.div("",
        data: { slot: "dialog-overlay", "shadcnrb--dialog--component-target": "backdrop",
                action: "click->shadcnrb--dialog--component#close" },
        class: style.backdrop
      )

      opts[:data] =
        (opts[:data] || {}).merge(slot: "dialog-content", "shadcnrb--dialog--component-target": "content")
      opts[:class] = Shadcnrb::TailwindMerge.call(style.content, opts[:class])

      panel = content_tag(:div, **opts) do
        body = if src
          frame_id = "dialog-frame-#{SecureRandom.hex(4)}"
          loading = block ? capture(&block) : content_tag(:p, "Loading...",
            class: "text-sm text-muted-foreground animate-pulse")
          frame_opts = { id: frame_id, "data-lazy-src": src }
          frame_opts["data-lazy-reload"] = "" if reload
          frame_opts["data-loading-html"] = loading.to_s if reload
          content_tag(:"turbo-frame", loading, **frame_opts)
        else
          scope.capture_block(&block)
        end
        close_btn = button(
          variant: :ghost,
          size: :"icon-sm",
          "aria-label": "Close",
          class: style.close_btn_pos,
          data: { slot: "dialog-close", action: "click->shadcnrb--dialog--component#close" }
        ) { icon(:x) }
        safe_join([ body, close_btn ])
      end

      safe_join([ backdrop, panel ])
    end

    def header(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.header, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "dialog-header")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def footer(scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.footer, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "dialog-footer")
      content_tag(:div, **opts) { scope.capture_block(&block) }
    end

    def title(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.title, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "dialog-title")
      content_tag(:h2, **opts) do
        block ? capture(&block) : name.to_s
      end
    end

    def description(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.description, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "dialog-description")
      content_tag(:p, **opts) do
        block ? capture(&block) : name.to_s
      end
    end

    # Wraps a button (or any content) so clicking it closes the dialog.
    # Usage: d.close { sui.button "Cancel", variant: :outline }
    def close(name = nil, scope: nil, **opts, &block)
      opts[:data] = (opts[:data] || {}).merge(slot: "dialog-close",
        action: "click->shadcnrb--dialog--component#close")
      if block
        content_tag(:span, **opts) { scope.capture_block(&block) }
      else
        button(name, **opts)
      end
    end

    private :trigger, :content, :header, :footer, :title, :description, :close
  end
end
