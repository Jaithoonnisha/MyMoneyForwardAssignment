Rails.application.config.after_initialize do
  begin
    User.find_or_create_by!(user_id: "TaroYamada") do |u|
      u.password = "password"
      u.nickname = "Taro"
      u.comment  = "I'm happy."
    end
  rescue => e
    Rails.logger.error "[SEED] Failed: #{e.message}"
  end
end
