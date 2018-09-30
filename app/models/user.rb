class User < ApplicationRecord
  validates :name, :username, :uid, :email, presence: true
  validates :uid, uniqueness: true
  # attr_encrypted :token, key: ENV["GH_TOKEN_KEY"]

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      if auth["info"]
        user.name = auth["info"]["name"] || ""
        user.email = auth["info"]["email"]
        user.username = auth["info"]["nickname"]
      end
      if auth["credentials"]
        # token received from Github payload
        github_token = auth["credentials"]["token"]

        # encrypting github_token using MessageEncryptor
        key = ENV["GH_TOKEN_KEY"]
        crypt = ActiveSupport::MessageEncryptor.new(key)
        user.encrypted_token = crypt.encrypt_and_sign(github_token)
        
      end
    end
  end
end
