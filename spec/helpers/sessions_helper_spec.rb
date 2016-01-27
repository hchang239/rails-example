require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SessionsHelper. For example:
#
# describe SessionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SessionsHelper, type: :helper do
  let!(:user) { FactoryGirl.create(:user) }

  describe 'Allow user to log_in and save the user_id to session' do
    before { helper.log_in(user) }

    it { expect(session[:user_id]).to eq(user.id) }
  end

  describe 'Return the current_user record' do
    context 'current user has not login yet' do
      it { expect(helper.current_user).to eq(nil) }
    end

    context 'the user just login and @current_user is initialized' do
      before { helper.log_in(user) }
      it { expect(helper.current_user).to eq(user) }
    end
  end

  describe 'Check if the current_user is logged in' do
    context 'the user is not logged in' do
      it { expect(helper.logged_in?).to eq(false) }
    end

    context 'the user is logged in' do
      before { helper.log_in user }
      it { expect(helper.logged_in?).to eq(true) }
    end
  end

  describe 'the user is logged out' do
    before do
      helper.log_in user
      helper.current_user
      helper.log_out
    end

    it { expect(session[:user_id]).to eq(nil) }
    it { expect(helper.current_user).to eq(nil) }
    it { expect(helper.logged_in?).to eq(false) }
  end
end