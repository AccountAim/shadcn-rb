# frozen_string_literal: true

module Shadcnrb
  # A thin carrier yielded by component blocks (`sui.dialog do |d| ... end`).
  # Holds the component instance and routes `d.trigger` →
  # `component.send(:trigger, ..., scope: self)`. Using `send` + `respond_to?
  # (name, true)` reaches PRIVATE methods on the component — orphan protection
  # falls out for free (`sui.dialog_trigger` simply doesn't exist).
  #
  # Sub-scopes (e.g. `:dropdown_menu_sub`) use `method_prefix:` to target a
  # prefixed method on the same component first (`sub.trigger` →
  # `sub_trigger`), falling back to the unprefixed method (`sub.item` →
  # `item`) — one component instance, two routing shapes.
  class Scope
    attr_reader :kind, :parent, :builder, :component

    def initialize(builder, kind:, component: nil, method_prefix: nil, parent: nil)
      @builder = builder
      @kind = kind
      @component = component
      @method_prefix = method_prefix
      @parent = parent
    end

    # Spawn a child scope. Used inside user-content blocks so helpers called
    # inside (e.g. `i.link_to`) see `parent: self` and can apply
    # context-aware defaults like `variant: :bare`.
    def child_scope(kind: @kind, component: @component, method_prefix: @method_prefix)
      Scope.new(@builder, kind:, component:, method_prefix:, parent: self)
    end

    # Capture a user-supplied block with a fresh child scope as the yielded
    # argument.
    def capture_block(&block)
      return "".html_safe unless block
      @builder.capture(child_scope, &block)
    end

    def method_missing(name, *args, **kwargs, &block)
      if @component
        if @method_prefix
          prefixed = :"#{@method_prefix}#{name}"
          if @component.respond_to?(prefixed, true)
            kwargs[:scope] = self unless kwargs.key?(:scope)
            return @component.send(prefixed, *args, **kwargs, &block)
          end
        end
        if @component.respond_to?(name, true)
          kwargs[:scope] = self unless kwargs.key?(:scope)
          return @component.send(name, *args, **kwargs, &block)
        end
      end

      if @builder.respond_to?(name, true)
        if accepts_scope?(name) && !kwargs.key?(:scope)
          kwargs[:scope] = self
        end
        return @builder.send(name, *args, **kwargs, &block)
      end

      super
    end

    def respond_to_missing?(name, include_private = false)
      return true if @component && (
        (@method_prefix && @component.respond_to?(:"#{@method_prefix}#{name}", true)) ||
        @component.respond_to?(name, true)
      )
      @builder.respond_to?(name, include_private) || super
    end

    # Helpers used directly on scope instances inside component blocks. Kept
    # here (rather than routed through `@builder`) because Builder's copies
    # are private.

    def content_with_icon(name = nil, icon: nil, &block)
      parts = []
      parts << self.icon(icon) if icon
      parts << name.to_s       if name.present?
      parts << capture(&block) if block
      return "".html_safe if parts.empty?
      safe_join(parts, " ")
    end

    def merge_action(data, *actions)
      [ data&.dig(:action), *actions ].compact.join(" ")
    end

    def safe_current_page?(options)
      return false if options.nil? || options == "#"
      current_page?(options)
    rescue StandardError
      false
    end

    private

    def accepts_scope?(name)
      @builder.method(name).parameters.any? { |_, n| n == :scope }
    end
  end
end
