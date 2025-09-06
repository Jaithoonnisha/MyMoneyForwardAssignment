Rails.application.config.after_initialize do
  begin
    if User.count == 0
      Rails.logger.info "[SEED] Creating default TrackTest user"
      User.create!(
        user_id: "TaroYamada",
        password: "PaSSwd4Ty",
        nickname: "Taro",
        comment: "I'm happy."
      )
    else
      Rails.logger.info "[SEED] Users already exist, skipping seed"
    end
  rescue => e
    Rails.logger.error "[SEED] Failed: #{e.message}"
  end
end
