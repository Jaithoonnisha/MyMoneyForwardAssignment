class User < ApplicationRecord
  validates :user_id,
            presence: true,
            uniqueness: true,
            length: { in: 6..20 },
            format: { with: /\A[a-zA-Z0-9]+\z/, message: "Incorrect character pattern" }

  validates :password,
            presence: true,
            length: { in: 8..20 },
            format: { with: /\A[\x21-\x7E]+\z/, message: "Incorrect character pattern" }
end