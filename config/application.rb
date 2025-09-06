require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
# Disabled unnecessary frameworks for API-only:
# require "active_storage/engine"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module AuthenticationApi
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 8.0
    config.load_defaults 8.0

    # Autoload lib/ while ignoring non-Ruby subdirs
    config.autoload_lib(ignore: %w[assets tasks])

    # API-only mode: no views, helpers, or assets
    config.api_only = true

    # Auto-run migrations on boot (so Railway always has schema ready)
    config.after_initialize do
      begin
        ActiveRecord::Base.connection
        if ActiveRecord::Base.connection.migration_context.needs_migration?
          ActiveRecord::Base.connection.migration_context.migrate
        end
      rescue => e
        Rails.logger.error "[MIGRATION] Failed: #{e.message}"
      end
    end
  end
end
