require_relative "lib/shadcn-rb"

Gem::Specification.new do |s|
  s.name         = "shadcn-rb"
  s.version      = Shadcnrb::VERSION
  s.summary      = "shadcn/ui components for Rails, via an ActionView Builder."
  s.description  = "A port of shadcn/ui to Ruby. Components are plain Ruby " \
                   "modules mixed into a Builder object, exposed in views " \
                   "as `sui`. Uses real Rails helpers (link_to, button_to, " \
                   "form_with) underneath."
  s.authors      = [ "accountaim" ]
  s.files        = Dir["README.md", "LICENSE", "lib/**/*", "app/**/*", "assets/**/*"]
  s.require_path = "lib"
  s.homepage     = "https://github.com/accountaim/shadcn-rb"
  s.license      = "MIT"

  s.required_ruby_version = ">= 3.2"

  # shadcnrb follows the "eject" model: the gem ships no runtime code, only
  # generators. After `bin/rails g shadcnrb:install` the host app owns every
  # file under `app/components/shadcnrb/` and declares the real runtime gems
  # (tailwind_merge, rouge) in its own Gemfile. Consumers should install this
  # gem into the `:development` group.
  s.add_development_dependency "actionview", ">= 7.1"
  s.add_development_dependency "activesupport", ">= 7.1"
  s.add_development_dependency "rouge", ">= 4.2"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "tailwind_merge", ">= 0.12"
end
