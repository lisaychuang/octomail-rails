class User < ApplicationRecord
  validates :name, :username, :uid, :email, presence: true
  validates :uid, uniqueness: true
  # attr_encrypted :token, key: ENV["GH_TOKEN_KEY"]

  has_many :repos, through: :notifications
  has_many :notifications

  def token
    # decrypting github_token using MessageEncryptor
    key = ENV["GH_TOKEN_KEY"]
    crypt = ActiveSupport::MessageEncryptor.new(key[0..31])
    crypt.decrypt_and_verify(self.encrypted_token)
  end

  # Creating new user upon authentication
  # Should handle update info at some point

  def self.create_with_omniauth(auth)
    create! do |user|
      set_omniauth_info(user, auth)
    end
  end

  def update_omniauth_info(auth)
    User.set_omniauth_info(self, auth)
    self.save
  end

  private
  # Class method
  def self.set_omniauth_info(user, auth) 
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
      crypt = ActiveSupport::MessageEncryptor.new(key[0..31])
      user.encrypted_token = crypt.encrypt_and_sign(github_token)
      
    end
  end

end
