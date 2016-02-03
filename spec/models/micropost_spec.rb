require 'rails_helper'

RSpec.describe Micropost, type: :model do
  it { should belong_to :user }
  it { should have_db_column :content }
  it { should have_db_index  [:user_id, :created_at] }
  it { should validate_presence_of :content }
  it { should validate_length_of(:content).is_at_most(140) }
end
