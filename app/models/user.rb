# == Schema Information
# Schema version: 20110102021039
#
# Table name: users
#
#  id                   :integer(4)      not null, primary key
#  name                 :string(255)     not null
#  email                :string(255)     default(""), not null
#  encrypted_password   :string(128)     default(""), not null
#  reset_password_token :string(255)
#  remember_token       :string(255)
#  remember_created_at  :datetime
#  sign_in_count        :integer(4)      default(0)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  password_salt        :string(255)
#  confirmation_token   :string(255)
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  failed_attempts      :integer(4)      default(0)
#  unlock_token         :string(255)
#  locked_at            :datetime
#  admin                :boolean(1)
#  created_at           :datetime
#  updated_at           :datetime
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#

class User < ActiveRecord::Base

  devise :confirmable, :database_authenticatable, :lockable, :omniauthable, :recoverable, :registerable, :rememberable, :recoverable, :validatable

  attr_accessible :email, :name, :password, :password_confirmation, :remember_me

  define_index do
    indexes :email,    sortable: true
    indexes :name,     sortable: true

    has confirmed_at, created_at, locked_at, updated_at
  end

  def self.find_for_facebook_oauth(auth_data, signed_in_resource=nil)
    email = auth_data['extra']['user_hash']['email']
    name = auth_data['extra']['user_hash']['name']
    if user = User.find_by_email(email)
      user
    else
      new_user = User.new(email: email, name: name, password: Devise.friendly_token[0,20])
      new_user.skip_confirmation!
      new_user.save!
    end
  end 

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["user_hash"]
        user.email = data["email"]
      end
    end
  end

end
