# frozen_string_literal: true

# shadcn divergence: child parts (`image`, `fallback`) are orphan-protected —
# they only render when called through a `:avatar`-kind `Shadcnrb::Scope`
# (yielded by `sui.avatar do |a| ... end`, or via `sui.avatar_proxy` for
# standalone renders).

module Shadcnrb
  class Avatar < Component
    def avatar(size: :default, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.root, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "avatar", size: size.to_s)
      content_tag(:span, **opts) do
        block ? capture(proxy, &block) : "".html_safe
      end
    end

    def proxy
      Scope.new(@builder, kind: :avatar, component: self)
    end

    # shadcn divergence: shadcn React's `AvatarImage` renders nothing until
    # the image loads, so `AvatarFallback` (rendered *after* it) shows during
    # load + on error. We don't have per-component JS state — `onerror`
    # removes the `<img>` node so the sibling fallback becomes visible
    # (the container uses overflow-hidden flex, so when both elements are
    # present only the image shows; remove it and fallback takes the space).
    def image(src:, alt: "", scope: nil, **opts)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.image, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "avatar-image")
      opts[:onerror] ||= "this.remove()"
      image_tag(src, alt:, **opts)
    end

    def fallback(name = nil, scope: nil, **opts, &block)
      opts[:class] = Shadcnrb::TailwindMerge.call(self.class.style.fallback, opts[:class])
      opts[:data] = (opts[:data] || {}).merge(slot: "avatar-fallback")
      content_tag(:span, **opts) do
        block ? capture(&block) : name.to_s
      end
    end

    private :image, :fallback
  end
end
