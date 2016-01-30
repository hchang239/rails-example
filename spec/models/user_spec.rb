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

  describe '.validates :email, uniqueness' do
    subject { FactoryGirl.build(:user, name: 'Valid Name') }
    it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
  end

  describe '.before_save' do
    let(:test_email) { 'MUST.BE.LOWERED@SAMPLE.COM' }
    let!(:user) { FactoryGirl.create(:user, name: 'Valid Name', email: test_email) }

    it { expect(user.email).to eq(test_email.downcase) }
  end

  describe '.new_token' do
    let!(:new_token) { SecureRandom.urlsafe_base64 }
    before { allow(SecureRandom).to receive(:urlsafe_base64) { new_token } }

    it { expect(User.new_token).to eq(new_token) }
  end

  describe '.digest(string)' do
    let(:token)   { 'test token' }
    let!(:digest) { User.digest(token) }
    subject { BCrypt::Password.new(digest).is_password?(token) }

    it { is_expected.to be_truthy }
  end

  describe '#remember' do
    let!(:user) { FactoryGirl.create(:user) }
    before do
      allow(User).to receive(:digest) { 'sample_token_digest' }
      user.remember
    end
    
    it { expect(user.remember_digest).to eq('sample_token_digest')}
  end

  describe '#authenticated?(remember_token)' do
    let!(:digest) { BCrypt::Password.create('valid token') }
    let!(:user) { FactoryGirl.create(:user, remember_digest: digest) }

    context 'when remember_token is valid' do
      subject { user.authenticated?('valid token') }
      it { is_expected.to be true }
    end

    context 'when remember_token is invalid' do
      subject { user.authenticated?(nil) }
      it { is_expected.to be false }
    end

    context 'when the user has no digest' do
      before { user.remember_digest = nil }
      subject { user.authenticated?('token') }
      it { is_expected.to be false }
    end
  end

  describe '#forget' do
    let(:user) { FactoryGirl.create(:user, remember_digest: "valid_digest") }
    it 'sets remember_token to nil' do
      expect{ user.forget }.to change(user, :remember_digest).from("valid_digest").to(nil)
    end
  end
end