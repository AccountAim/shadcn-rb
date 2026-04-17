# frozen_string_literal: true

module Shadcnrb
  class Typography < Component
    def h1(name = nil, size: :default, **opts, &block)
      heading(:h1, name, size:, **opts, &block)
    end

    def h2(name = nil, size: :default, **opts, &block)
      heading(:h2, name, size:, **opts, &block)
    end

    def h3(name = nil, size: :default, **opts, &block)
      heading(:h3, name, size:, **opts, &block)
    end

    def h4(name = nil, size: :default, **opts, &block)
      heading(:h4, name, size:, **opts, &block)
    end

    def p(name = nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.p, opts[:class])
      content_tag(:p, **opts) { block ? capture(&block) : name.to_s }
    end

    def lead(name = nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.lead, opts[:class])
      content_tag(:p, **opts) { block ? capture(&block) : name.to_s }
    end

    def muted(name = nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.muted, opts[:class])
      content_tag(:p, **opts) { block ? capture(&block) : name.to_s }
    end

    def code(name = nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.code, opts[:class])
      content_tag(:code, **opts) { block ? capture(&block) : name.to_s }
    end

    private

    def heading(tag, name = nil, size: :default, **opts, &block)
      style = self.class.style
      base  = style.public_send(tag)
      opts[:class] = Shadcnrb::TailwindMerge.call(base, style.heading_sizes[size], opts[:class])
      content_tag(tag, **opts) { block ? capture(&block) : name.to_s }
    end
  end
end
