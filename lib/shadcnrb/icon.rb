# frozen_string_literal: true

module Shadcnrb
  class Icon < Component
    # Renders a lucide icon as inline SVG.
    #
    # Lookup order:
    #   1. If `lucide-rails` is loaded, delegates to `lucide_icon()` — gives
    #      the host app access to all ~2000 lucide icons with no bundling.
    #   2. Otherwise reads SVGs from `app/components/shadcnrb/icon/icons/<name>.svg`
    #      (the installer copies a minimal bundled set; drop more in there
    #      to extend coverage).
    def icon(name, size: nil, **opts)
      klass = icon_class(size, opts.delete(:class))

      if defined?(::LucideRails)
        return @builder.view_context.lucide_icon(name.to_s, class: klass, **opts)
      end

      svg = read_icon(name)
      return "".html_safe unless svg
      svg.sub(/<svg\b/, %(<svg class="#{klass}")).html_safe
    end

    private

    def icon_class(size, custom)
      base = case size
      when :sm then "size-3"
      when :lg then "size-5"
      else "size-4"
      end
      Shadcnrb::TailwindMerge.call(base, custom)
    end

    def read_icon(name)
      f = Rails.root.join("app/components/shadcnrb/icon/icons/#{name}.svg")
      File.exist?(f) ? File.read(f) : nil
    end
  end
end
