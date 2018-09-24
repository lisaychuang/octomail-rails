class User < ApplicationRecord
  validates :name, :username, :uid, :email, presence: true
  validates :uid, uniqueness: true
  attr_encrypted :token, key: ENV["GH_TOKEN_KEY"]

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
         user.email = auth['info']['email'] 
         user.username = auth['info']['nickname'] 
      end
      if auth['credentials']
        user.token = auth['credentials']['token'] 
      end
    end
  end

end
