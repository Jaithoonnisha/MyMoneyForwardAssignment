Rails.application.config.after_initialize do
  begin
    if User.count == 0
      Rails.logger.info "[SEED] Creating default TrackTest user..."
      User.create!(
        user_id: "TaroYamada",
        password: "password",
        nickname: "Taro",
        comment: "I'm happy."
      )
    else
      Rails.logger.info "[SEED] Users already exist, skipping."
    end
  rescue => e
    Rails.logger.error "[SEED] Failed: #{e.message}"
  end
end
