# frozen_string_literal: true

# shadcn divergence: custom Stimulus-based toasts instead of Sonner. Adds
# server-rendered static toast for SSR, Turbo-Stream `toast_stream` helper,
# and automatic `flash_toasts` from Rails flash. upstream: sonner.tsx.

module Shadcnrb
  class Toast < Component
    # Wraps a trigger (a button, a link, whatever). Click anywhere inside
    # appends a toast to a lazily-created body-level container. No `toaster`
    # container needs to exist on the page.
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
      opts[:class] = classes_from_style(self.class.style, variant:, custom: opts[:class])
      opts[:data] = (opts[:data] || {}).merge(controller: "shadcnrb--toast--component")
      content_tag(:div, **opts) do
        if block
          capture(&block)
        else
          content_tag(:div) do
            safe_join([
              content_tag(:p, title, class: "text-sm font-semibold"),
              description ? content_tag(:p, description,
                class: "text-sm opacity-90") : "".html_safe
            ])
          end
        end
      end
    end

    # Render any pending Rails flash messages as toasts. Drop this in your
    # layout:
    #   <%= sui.flash_toasts %>
    # Maps flash keys to variants — :notice → :default, :alert / :error → :destructive,
    # :success → :default.
    def flash_toasts
      messages = @builder.view_context.flash.map do |key, msg|
        next if msg.blank?
        variant = flash_variant_for(key)
        toast(msg.to_s, variant:)
      end.compact
      safe_join(messages)
    end

    # Build a Turbo Stream that appends a toast to the body-level toasts
    # container. Usage from a controller that responds to turbo_stream:
    #   render turbo_stream: sui.toast_stream("Saved", variant: :default)
    def toast_stream(message, description: nil, variant: :default)
      body = @builder.view_context.render(
        inline: <<~ERB,
          <%= sui.toast(message, description: description, variant: variant) %>
        ERB
        locals: { message:, description:, variant: }
      )
      @builder.view_context.turbo_stream.append("shadcnrb-toasts", body)
    end

    private

    def flash_variant_for(key)
      case key.to_s.to_sym
      when :alert, :error then :destructive
      else :default
      end
    end
  end
end
