# frozen_string_literal: true

begin
  require "tailwind_merge"
rescue LoadError
  raise LoadError, <<~MSG
    shadcnrb requires the `tailwind_merge` gem but it is not installed.
    Add it to your Gemfile:

      bundle add tailwind_merge

    (Normally `bin/rails g shadcnrb:install` handles this for you.)
  MSG
end

module Shadcnrb
  # Service wrapper around the `tailwind_merge` gem. `call` merges class
  # strings with shadcn's variant table lookup plumbing layered on top.
  module TailwindMerge
    MERGER = ::TailwindMerge::Merger.new.freeze

    module_function

    def call(*classes)
      MERGER.merge(classes.compact.flatten.map { |c| c.to_s.strip }.reject(&:empty?).join(" "))
    end

    # Look up a variant/size key; raise on unknown keys in every env so
    # typos surface immediately rather than silently rendering fallback
    # styles in production.
    def fetch_variant(table, key, kind: :variant, component: "component")
      return table[key] if table.key?(key)
      sym = key.to_sym if key.respond_to?(:to_sym)
      return table[sym] if sym && table.key?(sym)

      valid = table.keys.map(&:inspect).join(", ")
      raise ArgumentError,
        "Unknown #{component} #{kind} #{key.inspect}. Valid: [#{valid}]"
    end
  end
end
