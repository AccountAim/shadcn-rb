# frozen_string_literal: true

# shadcn divergence: custom Stimulus-based toasts instead of Sonner. `toaster`
# is sonner's `<Toaster />`: the positioned container, pending flash messages,
# and one `<template>` per variant that the trigger controller clones — so
# JS-created toasts share the server markup. Adds a Turbo-Stream
# `toast_stream` helper. upstream: sonner.tsx.

module Shadcnrb
  class Toast < Component
    CONTAINER_ID = "shadcnrb-toasts"

    # The body-level toasts container. Drop it in your layout once:
    #   <%= sui.toaster position: "bottom-right" %>
    def toaster(position: "top-right", **opts)
      style = self.class.style
      position_class = Shadcnrb::TailwindMerge.fetch_variant(
        style.positions, position, kind: :position, component: "toast"
      )

      opts[:id] ||= CONTAINER_ID
      opts[:class] = Shadcnrb::TailwindMerge.call(style.container, position_class, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "toaster")
      content_tag(:div, **opts) { safe_join([ *templates, flash_toasts ]) }
    end

    # Wraps a trigger (a button, a link, whatever). Click anywhere inside
    # appends a toast cloned from the toaster's template for `variant`.
    #
    #   <%= sui.toast_trigger title: "Saved", description: "All good." do %>
    #     <%= sui.button "Show", variant: :outline %>
    #   <% end %>
    def toast_trigger(title:, description: nil, variant: :default, duration: 5000, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.trigger_wrapper, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(
        controller: "shadcnrb--toast--trigger",
        action: "click->shadcnrb--toast--trigger#show",
        "shadcnrb--toast--trigger-title-value": title.to_s,
        "shadcnrb--toast--trigger-description-value": description.to_s,
        "shadcnrb--toast--trigger-variant-value": variant.to_s,
        "shadcnrb--toast--trigger-duration-value": duration.to_s
      )
      content_tag(:span, **opts, &block)
    end

    # Static, server-rendered toast (rare — usually you want `toast_trigger`).
    def toast(title = nil, description: nil, variant: :default, **opts, &block)
      style = self.class.style
      opts[:class] = classes_from_style(style, variant:, custom: opts[:class])
      opts[:data] = (opts[:data] || {}).merge(
        slot: "toast", controller: "shadcnrb--toast--component"
      )

      content_tag(:div, **opts) do
        next capture(&block) if block

        icon = style.icons[variant.to_sym]
        safe_join([
          icon && @builder.icon(icon[:name], class: icon[:class]),
          content_tag(:div, class: "flex-1") do
            safe_join([
              content_tag(:p, title, class: style.title, data: { slot: "toast-title" }),
              description && content_tag(:p, description, class: style.description,
                data: { slot: "toast-description" })
            ].compact)
          end,
          close_button
        ].compact)
      end
    end

    # Render any pending Rails flash messages as toasts. Maps flash keys to
    # variants — :alert / :error → :destructive, everything else → :default.
    def flash_toasts
      messages = @builder.view_context.flash.map do |key, msg|
        next if msg.blank?
        variant = flash_variant_for(key)
        toast(msg.to_s, variant:)
      end.compact
      safe_join(messages)
    end

    # Build a Turbo Stream that appends a toast to the toaster. Usage from a
    # controller that responds to turbo_stream:
    #   render turbo_stream: sui.toast_stream("Saved", variant: :default)
    def toast_stream(message, description: nil, variant: :default)
      body = @builder.view_context.render(
        inline: <<~ERB,
          <%= sui.toast(message, description: description, variant: variant) %>
        ERB
        locals: { message:, description:, variant: }
      )
      @builder.view_context.turbo_stream.append(CONTAINER_ID, body)
    end

    private

    # One `<template>` per variant with an empty title and description; the
    # trigger controller fills them in.
    def templates
      self.class.style.variants.keys.map do |variant|
        content_tag(:template, data: { slot: "toast-template", variant: }) do
          toast(nil, description: "", variant:)
        end
      end
    end

    def close_button
      content_tag(:button, type: "button", "aria-label": "Close", class: self.class.style.close,
        data: { action: "click->shadcnrb--toast--component#dismiss" }) do
        @builder.icon(:x, class: "size-4")
      end
    end

    def flash_variant_for(key)
      case key.to_s.to_sym
      when :alert, :error then :destructive
      else :default
      end
    end
  end
end
