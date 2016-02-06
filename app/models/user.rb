class User < ActiveRecord::Base
  # create instance variable(@) and define getter & setter
  attr_accessor :remember_token, :activation_token, :reset_token

  before_save   :downcase_email
  before_create :create_activation_digest

  has_many :microposts, dependent: :destroy

  # Tells rails what class should be used
  # because association name is different from class_name
  has_many :active_relationships, class_name:  'Relationship',
                                  foreign_key: :follower_id,
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  'Relationship',
                                   foreign_key: :followed_id,
                                   dependent:   :destroy

  # Eventually we want to call user.following to find all followed users by this
  # source: :followed defines the source of the following array is the set of followed_ids
  has_many :following, through: :active_relationships,  source: :followed

  # user.followers returns all users who follow the current user
  # source: :follower defines the source of the followers array in the set of follower_ids
  # In this case, we don't need to set source because Rails will automatically find follower_id
  # which is singularized :followers attribute
  has_many :followers, through: :passive_relationships, source: :follower

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
    # update_columns & update_attribute methods skip the validation and callbacks
    # However update_attributes method DOES check validations and callbacks
    # update_columns & update_attributes methods touch DB only once
    update_columns(activated: true, 
                   activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    # This is equivalent to self.microposts
    # However this returns ActiveRecord::Relation
    # self.microposts returns ActiveRecord::Associations::CollectionProxy

    # following_ids is defined by ActiveRecord association which is equivalent to
    # user.following.map(&:id) [Note: source of following is :followed]
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)

    # Instead of using ? for sanitizing, you can use hash:
    #   .where("user_id IN (:following_ids) OR user_id = :user_id",
    #          following_ids: following_ids, user_id: id)

    # Optimize query with SQL subselect
    following_ids = "SELECT followed_id FROM relationships
                     WHERE   follower_id = :user_id"
    Micropost.where("user_id IN (#{ following_ids }) OR user_id = :user_id", user_id: id)
  end

  # Follows a user
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollow a user
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user
  def following?(other_user)
    following.include?(other_user)
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