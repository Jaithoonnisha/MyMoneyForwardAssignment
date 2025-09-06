class User < ApplicationRecord
  validate :user_id_and_password_required
  validates :user_id,
            uniqueness: { message: "Already same user_id is used" },
            length: { in: 6..20, message: "Input length is incorrect" },
            format: { with: /\A[a-zA-Z0-9]+\z/, message: "Incorrect character pattern" }
  validates :password,
            length: { in: 8..20, message: "Input length is incorrect" },
            format: { with: /\A[\x21-\x7E]+\z/, message: "Incorrect character pattern" }

  private
  def user_id_and_password_required
    if user_id.blank? || password.blank?
      errors.add(:base, "Required user_id and password")
    end
  end
end
