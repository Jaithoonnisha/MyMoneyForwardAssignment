module AuthenticationApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])

    # API-only mode
    config.api_only = true

    # 🚀 Auto-run migrations on boot (for Railway deploys)
    config.after_initialize do
      begin
        ActiveRecord::Base.connection
        if ActiveRecord::Base.connection.migration_context.needs_migration?
          Rails.logger.info "[MIGRATION] Running pending migrations..."
          ActiveRecord::MigrationContext.new(
            ActiveRecord::Migrator.migrations_paths,
            ActiveRecord::SchemaMigration
          ).migrate
        end
      rescue => e
        Rails.logger.error "[MIGRATION] Failed: #{e.message}"
      end
    end
  end
end
