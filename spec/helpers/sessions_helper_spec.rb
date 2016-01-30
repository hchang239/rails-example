require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  let!(:user) { FactoryGirl.create(:user, remember_token: 'valid_token') }

  describe '#log_in(user)' do
    before { helper.log_in(user) }
    it { expect(session[:user_id]).to eq(user.id) }
  end

  describe '#remember(user)' do
    before { helper.remember user }

    it { expect(cookies.signed[:user_id]).to eq(user.id) }
    it { expect(cookies[:remember_token]).to eq(user.remember_token) }
  end

  describe '#current_user' do

    context 'when user is already logged in' do
      before { session[:user_id] = user.id }
      it { expect(helper.current_user).to eq(user) }
    end

    context 'when the user is logging in with remember_token' do
      before do
        allow(User).to receive(:find_by_id).with(user.id) { user }
        allow(user).to receive(:authenticated?) { true }
        cookies.signed[:user_id] = user.id
      end

      it { expect(session[:user_id]).to be_nil }
      it { expect(helper.current_user).to eq(user) }
    end
  end

  describe '#logged_in?' do
    subject { helper.logged_in? }

    context 'the user is not logged in' do
      it { is_expected.to be false }
    end

    context 'the user is logged in' do
      before { allow(helper).to receive(:current_user) { user } }
      it { is_expected.to be true }
    end
  end

  describe '#log_out' do
    before { session[:user_id] = user.id }

    it { expect{ helper.log_out }.to change{ session[:user_id] }.from(user.id).to(nil) }
    it { expect(assigns(:current_user)).to be_nil }
  end

  describe '#forget' do
    before do
      cookies.signed[:user_id] = user.id
      cookies[:remember_token] = user.remember_token
      allow(user).to receive(:forget)
      helper.forget user
    end

    it { expect(cookies.signed[:user_id]).to be_nil }
    it { expect(cookies[:remember_token]).to be_nil }
  end
end