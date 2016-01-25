require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_db_column(:name).of_type(:string) }
  it { should have_db_column(:email).of_type(:string) }
  it { should allow_values('valid@email.com', 'another_valid.email@example.com').for(:email) }
  it { should_not allow_values('@invalid.com', 'no space-test@allowed.net').for(:email) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :email }
  it { should validate_presence_of :password }
  it { should validate_length_of(:name).is_at_most(50) }
  it { should validate_length_of(:email).is_at_most(255) }
  it { should validate_length_of(:password).is_at_least(6) }

  it { should have_secure_password }

  describe 'only accept unique email' do
    subject { FactoryGirl.build(:user, name: 'Valid Name') }
    it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
  end

  describe 'change email to downcase before save' do
    let(:test_email) { 'MUST.BE.LOWERED@SAMPLE.COM' }
    let!(:user) { FactoryGirl.create(:user, name: 'Valid Name', email: test_email) }
    it { expect(user.email).to eq(test_email.downcase) }
  end
end