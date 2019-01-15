class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name,  presence: true, length:
    {maximum: Settings.user.name.max_length}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length:
    {maximum: Settings.user.email.max_length},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive: false}
  has_secure_password
  validates :password, presence: true, length:
    {minimum: Settings.user.password.min_length}, allow_nil: true
  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

    def remember
      self.remember_token = User.new_token
      update_attribute(:remember_digest, User.digest(remember_token))
    end

    def authenticated? attribute, token
      digest = send "#{attribute}_digest"
      BCrypt::Password.new(digest).is_password?(token) if digest
    end

    def forget
      update_attribute(:remember_digest, nil)
    end

    def activate
      update_attributes(activated: true, activated_at: Time.zone.now)
    end

    def send_activation_email
      UserMailer.account_activation(self).deliver_now
    end

    private
    # Convert email to all lower-case.
    def downcase_email
      email.downcase!
    end

    # Create and assigns the activation token and digest.
    def create_activation_digest
      activation_token = User.new_token
      activation_digest = User.digest activation_token
    end
end
