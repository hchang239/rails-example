require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

  # it { should route(:get, login_path).to('sessions#new') }
  it { should route(:post, login_path).to('sessions#create') }
  it { should route(:delete, logout_path).to('sessions#destroy') }

  describe "GET #new" do
    before { get :new }

    it { should respond_with(:success) }
    it { should render_template(:new) }
  end

  describe 'POST #create' do
    context 'successful login' do
      let!(:user) { FactoryGirl.create(:user) }
      let(:params) { { session: { email: user.email, password: user.password } } }
      before { post :create, params }

      it { should redirect_to(user_path(user)) }
    end

    context 'login failure' do
      let(:params) { { session: { email: '', password: '' } } }
      before { post :create, params }

      it { should set_flash.now[:danger] }
      it { should render_template(:new) }
    end
  end

  describe 'DELETE #destroy' do
    before { delete :destroy }

    it { should redirect_to(root_url) }
  end

end