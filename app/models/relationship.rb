# Relationship stores active_ (following) and passive_ (followed) relationships for users
class Relationship < ActiveRecord::Base
  # belongs_to uses attribute name to decide foreign key and class name
  # e.g. <class>_id, <class>
  # Since the foreign key and class name is unmatched,
  # you should provide class_name explicitly
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'
end