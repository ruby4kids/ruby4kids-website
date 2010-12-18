class Account < ActiveRecord::Base

  require 'digest/sha1'
  include AccountRoleRight
  
  belongs_to :person
  has_and_belongs_to_many :roles

  validates_presence_of :password, :if => :validate_password?
  validates_uniqueness_of   :username
  validates_presence_of     :username
  validates_uniqueness_of   :email
  validates_presence_of     :email
  validates_format_of(:email, 
                      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, 
                      :message=>"has an invalid format")

  validates_length_of	:password, :minimum => 5, :message => "Should be at least 5 characters.", :if => :validate_password?
  attr_accessor :password_confirmation
  validates_confirmation_of :password, :if => :validate_password?


   # authentication of the account
  def self.authenticate(username, password)
    account = self.find_by_username(username)
    if account
      expected_password = encrypted_password(password, account.salt)
      if account.hashed_password != expected_password
        account = nil
      end
    end
    account
  end

  def password
    @password
  end

  def password=(pwd)
    @password = pwd
    create_new_salt
    self.hashed_password = Account.encrypted_password(self.password, self.salt)
  end

  def self.validate_password=(validate)
    @validate_password = validate
  end

  def validate_password?
    @validate_password
  end

  def validate
    errors.add_to_base("Missing password hashed") if (hashed_password.blank? and validate_password?)
  end

  protected
  
  def self.join_table_mappings
    return {
        "account" => {
          "model_name" => Account,
          "table_name" => "accounts",
          "join_relationships" => ""
        }
      }
  end
    
  private

  def self.encrypted_password(password, salt)
    string_to_hash = password + "wi7rle5dx" + salt  
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end


end
