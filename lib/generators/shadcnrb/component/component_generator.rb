# frozen_string_literal: true

require "rails/generators"
require "yaml"

module Shadcnrb
  module Generators
    class ComponentGenerator < Rails::Generators::Base
      namespace "shadcnrb:component"

      # Source root is the gem's `lib/shadcnrb/`. Each component lives in its
      # own subdir (`<name>/component.rb` + `<name>/style.rb` + any
      # `*_controller.js` siblings); we copy the whole dir into
      # `app/components/shadcnrb/<name>/`.
      source_root File.expand_path("../../../shadcnrb", __dir__)

      argument :component_name, type: :string, required: true
      class_option :force, type: :boolean, default: false

      def check_component
        unless component_dir_exists?
          say "Unknown component: #{component_name}", :red
          say "Available: #{available_components.join(', ')}", :yellow
          exit 1
        end
      end

      def copy_component_dir
        # The component class lives at `lib/shadcnrb/<name>.rb` (sibling to
        # the dir) — e.g. `Shadcnrb::Dialog` — so Zeitwerk can autoload it
        # as the namespace for the nested `Shadcnrb::Dialog::Component`,
        # `Shadcnrb::Dialog::Style` etc. Copy it alongside the dir.
        if File.file?(component_class_file)
          dst = Rails.root.join("app/components/shadcnrb/#{component_name}.rb")
          say_status :create, "app/components/shadcnrb/#{component_name}.rb"
          copy_file component_class_file, dst, force: options["force"]
        end

        # Recursive so nested asset dirs (e.g. `icon/icons/*.svg`) come along
        # with the component — each component stays self-contained.
        Dir.glob(File.join(component_dir, "**/*")).each do |src|
          next unless File.file?(src)
          rel = src.sub(%r{\A#{Regexp.escape(component_dir)}/}, "")
          dst = Rails.root.join("app/components/shadcnrb/#{component_name}/#{rel}")
          say_status :create, "app/components/shadcnrb/#{component_name}/#{rel}"
          copy_file src, dst, force: options["force"]
        end
      end

      def install_component_dependencies
        component_deps.each do |dep|
          say_status :depend, "#{dep} (required by #{component_name})"
          run "bin/rails generate shadcnrb:component #{dep} #{'--force' if options['force']}"
        end
      end

      def wire_into_builder
        return if skip_wire?

        builder_path = Rails.root.join("app/components/shadcnrb/builder.rb")
        return unless File.exist?(builder_path)

        include_line = "  include Shadcnrb::#{component_name.camelize}::Component\n"
        content = File.read(builder_path)
        if content.lines.any? { |l| l.chomp == include_line.chomp }
          say_status :identical, "builder.rb (#{component_name} already included)"
          return
        end

        say_status :insert, 
"app/components/shadcnrb/builder.rb (include Shadcnrb::#{component_name.camelize}::Component)"
        inject_into_file builder_path,
          include_line,
          before: "  # END generated component includes"
      end

      private

      def component_dir
        File.join(self.class.source_root, component_name)
      end

      def component_class_file
        File.join(self.class.source_root, "#{component_name}.rb")
      end

      def component_dir_exists?
        File.directory?(component_dir) && File.exist?(File.join(component_dir, "component.rb"))
      end

      def available_components
        Dir.glob(File.join(self.class.source_root, "*"))
          .select { |p| File.directory?(p) && File.exist?(File.join(p, "component.rb")) }
          .map { |p| File.basename(p) }
          .sort
      end

      def dependencies
        @dependencies ||= YAML.load_file(File.expand_path("dependencies.yml", __dir__))
      end

      def component_deps
        dependencies.dig(component_name, "components") || []
      end

      # Components that are classes (e.g. FormBuilder < ActionView::Helpers::
      # FormBuilder) can't be `include`d into the Builder; opt out here.
      def skip_wire?
        dependencies.dig(component_name, "skip_wire") == true
      end
    end
  end
end
