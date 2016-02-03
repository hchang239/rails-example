class User < ActiveRecord::Base
  # create instance variable(@) and define getter & setter
  attr_accessor :remember_token, :activation_token

  before_save   :downcase_email
  before_create :create_activation_digest

  validates :name,  presence: true, length: { maximum: 50 }
  
  VALID_EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  # has_secure_password validates presence of password for a new user by default
  # Thus 'allow_nil: true' will allow the user to pass nil password for editing profile
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # Returns the hash digest of the given string
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(attribute, token)
    # Metaprogramming to call attribute getter => user.send('attribute_digest')
    digest = send("#{attribute}_digest")
    return false if digest.blank?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    update_attributes({ activated:    true,
                        activated_at: Time.zone.now })
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

    def downcase_email
      # use 'self' when setting attributes
      self.email = email.downcase
    end

    def create_activation_digest
      self.activation_token  = User.new_token
      # this is called in before_create where the user is NOT created yet.
      # So it just sets activation_digest attributes instead of calling update_attribute
      self.activation_digest = User.digest(activation_token)
    end
end