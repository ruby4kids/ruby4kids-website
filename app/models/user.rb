# == Schema Information
# Schema version: 20101219063520
#
# Table name: users
#
#  id                   :integer(4)      not null, primary key
#  username             :string(255)     not null
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
#  index_users_on_username              (username) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#

class User < ActiveRecord::Base

  devise :confirmable, :database_authenticatable, :lockable, :recoverable, :rememberable, :recoverable, :validatable

  attr_accessor :login

  attr_accessible :email, :login, :name, :password, :password_confirmation, :remember_me, :username

  define_index do
    indexes :username, sortable: true
    indexes :email,    sortable: true
    indexes :name,     sortable: true

    has confirmed_at, created_at, locked_at, updated_at
  end

  def self.find_for_database_authentication(conditions)
    auth_key = conditions[authentication_keys.first]
    where(['email = ? OR username = ?', auth_key, auth_key]).first
  end

end
