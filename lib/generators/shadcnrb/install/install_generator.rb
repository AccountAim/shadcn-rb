# frozen_string_literal: true

require "rails/generators"

module Shadcnrb
  module Generators
    class InstallGenerator < Rails::Generators::Base
      # Files copied verbatim from the gem's `lib/shadcnrb/` into the host's
      # `app/components/shadcnrb/`. The host owns these files after install —
      # the gem itself ships no runtime code. Paths are relative to the gem's
      # `lib/shadcnrb/` root and preserved in the destination.
      INFRA_FILES = %w[
        base_builder.rb
        tailwind_merge.rb
        component.rb
        scope.rb
        view_helpers.rb
        style.rb
      ].freeze

      namespace "shadcnrb:install"
      source_root File.expand_path("templates", __dir__)

      def check_runtime_gems
        # tailwind_merge is the one universal runtime dep — every copied
        # component calls `Shadcnrb::TailwindMerge.call` which requires it.
        # Other gems (rouge for codeblock, etc.) are added per-component.
        gem = "tailwind_merge"
        say_status :check, "#{gem} gem"
        return if gem_in_bundle?(gem)

        say "Adding #{gem} to Gemfile"
        run "bundle add #{gem}"
      end

      # Files from prior architectures that the current gem no longer ships.
      # `install --force` overwrites the live files but doesn't prune
      # stragglers — Zeitwerk would still try to autoload them and crash.
      # Prune them up front so the install lands clean.
      STALE_FILES = %w[
        app/components/shadcnrb/component_base.rb
        app/components/shadcnrb/component_proxy.rb
      ].freeze
      STALE_PER_COMPONENT = %w[proxy.rb].freeze

      def remove_stale_files
        STALE_FILES.each do |rel|
          path = Rails.root.join(rel)
          next unless File.exist?(path)
          say_status :remove, "#{rel} (obsolete in current shadcnrb)"
          File.delete(path)
        end

        components_root = Rails.root.join("app/components/shadcnrb")
        return unless File.directory?(components_root)
        Dir.glob(components_root.join("*", "{#{STALE_PER_COMPONENT.join(',')}}")).each do |path|
          rel = path.sub("#{Rails.root}/", "")
          say_status :remove, "#{rel} (obsolete in current shadcnrb)"
          File.delete(path)
        end
      end

      def copy_infra_files
        src_root = File.expand_path("../../../shadcnrb", __dir__)
        INFRA_FILES.each do |file|
          dst = Rails.root.join("app/components/shadcnrb/#{file}")
          say_status :create, "app/components/shadcnrb/#{file}"
          copy_file File.join(src_root, file), dst
        end
      end

      def create_initializer
        target = Rails.root.join("config/initializers/shadcnrb.rb")
        say_status :create, "config/initializers/shadcnrb.rb"
        template "shadcnrb.rb.tt", target
      end

      def copy_builder
        target = Rails.root.join("app/components/shadcnrb/builder.rb")
        if File.exist?(target)
          say_status :identical, 
"app/components/shadcnrb/builder.rb (keeping existing — would clobber component includes)"
          return
        end
        say_status :create, "app/components/shadcnrb/builder.rb"
        template "builder.rb.tt", target
      end

      def add_tailwind_css
        css_path = Rails.root.join("app/assets/tailwind/application.css")
        if File.exist?(css_path)
          say_status :update, "app/assets/tailwind/application.css (overwriting with shadcn tokens)"
          template "tailwind.css.erb", css_path, force: true
        else
          say_status :skip, 
"app/assets/tailwind/application.css not found — add the tokens manually"
        end
      end

      def add_tailwind_themes
        # Ships alongside application.css. Imported via `@import "./shadcnrb_themes.css"`.
        # Skip if the user already has a customized copy; otherwise always refresh.
        themes_path = Rails.root.join("app/assets/tailwind/shadcnrb_themes.css")
        if File.exist?(themes_path)
          say_status :identical, "app/assets/tailwind/shadcnrb_themes.css (keeping existing)"
        else
          say_status :create, "app/assets/tailwind/shadcnrb_themes.css"
          template "shadcnrb_themes.css.erb", themes_path
        end
      end

      def wire_stimulus_importmap
        importmap_path = Rails.root.join("config/importmap.rb")
        unless File.exist?(importmap_path)
          say_status :skip, "config/importmap.rb not found — add the pin manually"
          return
        end

        # Pin each co-located `_controller.js` under the `controllers/`
        # namespace that Stimulus's stock `eagerLoadControllersFrom` already
        # walks — that way vanilla identifier derivation (`/` → `--`) gives
        # us `shadcnrb--<dir>--<basename>` without any custom loader.
        # `to: ""` sends the served URL to `<dir>/<basename>.js` which
        # propshaft resolves via `app/components/shadcnrb` on its load path
        # (see the initializer).
        pin_line = %(pin_all_from "app/components/shadcnrb", ) +
                   %(under: "controllers/shadcnrb", to: ""\n)
        content = File.read(importmap_path)
        if content.include?(%(under: "controllers/shadcnrb"))
          say_status :identical, "config/importmap.rb (shadcnrb pin already present)"
          return
        end

        say_status :insert, "config/importmap.rb (pin controllers/shadcnrb/*)"
        append_to_file importmap_path, pin_line
      end

      def install_icon_component
        # Icon is borderline-required — the bundled SVGs are useless without
        # it and several other components (alert, breadcrumb, empty,
        # dropdown_menu) depend on it. Auto-install so `sui.icon` works
        # immediately after setup.
        say_status :install, "icon component (auto-included)"
        run "bin/rails generate shadcnrb:component icon"
      end

      def post_install_message
        say ""
        say "✔ shadcnrb installed.", :green
        say ""
        say "Next: pick the components you want —"
        say "  bin/rails g shadcnrb:component button"
        say "  bin/rails g shadcnrb:component dialog"
        say ""
        say "Then use them in any ERB/Slim view:"
        say "  <%= sui.button \"Save\", variant: :default %>"
        say '  <%= sui.button_to "Delete", record_path(r), method: :delete %>'
      end

      private

      # Reads the live Gemfile instead of Gem::Specification so we pick up
      # gems that `bundle add` wrote seconds ago in the same process.
      def gem_in_bundle?(name)
        gemfile = Rails.root.join("Gemfile")
        return false unless File.exist?(gemfile)
        File.read(gemfile).match?(/^\s*gem\s+["']#{Regexp.escape(name)}["']/)
      end
    end
  end
end
