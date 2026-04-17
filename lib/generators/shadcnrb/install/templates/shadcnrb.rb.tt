# frozen_string_literal: true

module Shadcnrb; end

# Register `app/components/shadcnrb/` as a root namespaced to `Shadcnrb`,
# so files there resolve to `Shadcnrb::X` rather than `Components::Shadcnrb::X`.
Rails.autoloaders.main.push_dir(
  Rails.root.join("app/components/shadcnrb").to_s,
  namespace: Shadcnrb
)

# Propshaft / Sprockets: serve co-located controller JS. Without this, the
# importmap pin `controllers/shadcnrb/<name>/component_controller` resolves to
# a URL the asset pipeline can't find, and the browser aborts with `Failed to
# resolve module specifier`.
Rails.application.config.assets.paths << Rails.root.join("app/components/shadcnrb").to_s

# Expose `sui` on every ActionView instance without touching the host's
# ApplicationHelper. Comment this out if you'd rather mix `Shadcnrb::ViewHelpers`
# in yourself (e.g. scoped to a specific controller).
ActiveSupport.on_load(:action_view) do
  include Shadcnrb::ViewHelpers
end
