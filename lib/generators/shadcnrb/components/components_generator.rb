# frozen_string_literal: true

require "rails/generators"
require_relative "../component/component_generator"

module Shadcnrb
  module Generators
    # Bulk-install every available component. Delegates to
    # `shadcnrb:component <name>` per entry so dependency resolution,
    # Stimulus copying, and Builder wiring all reuse the single-component
    # path — no drift between the two generators.
    class ComponentsGenerator < Rails::Generators::Base
      namespace "shadcnrb:components"

      source_root File.expand_path("../../../shadcnrb", __dir__)
      class_option :force, type: :boolean, default: false

      def generate_all_components
        components = Dir.glob(File.join(self.class.source_root, "*"))
          .select { |p| File.directory?(p) && File.exist?(File.join(p, "component.rb")) }
          .map    { |p| File.basename(p) }
          .sort

        say "Installing #{components.size} components..."
        components.each do |name|
          run "bin/rails generate shadcnrb:component #{name} #{'--force' if options['force']}".strip
        end
      end
    end
  end
end
