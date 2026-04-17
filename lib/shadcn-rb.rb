# frozen_string_literal: true

# shadcnrb follows the "eject" model: after `bin/rails g shadcnrb:install` the
# host app owns every Ruby file under `app/components/shadcnrb/`. The gem
# itself ships no runtime code — it only provides generators that copy source
# files into the host. This means you can put `gem "shadcn-rb"` in the
# `:development` group.

module Shadcnrb
  VERSION = "0.2.0"
end
