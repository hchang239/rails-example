class Micropost < ActiveRecord::Base
  belongs_to :user

  # '->' is called 'stabby lambda' (anonymous function)
  # It takes in a block and returns a Proc, which can be evaluated with the 'call' method
  default_scope -> { order(created_at: :desc) }

  validates :content, presence: true, length: { maximum: 140 }
end
