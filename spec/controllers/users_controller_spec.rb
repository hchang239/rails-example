require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  it { should route(:get, signup_path).to(action: :new) }
  it { should route(:post, users_path).to(action: :create) }

  describe 'GET #index' do
    context 'when user is not logged in' do
      subject { get :index }
      it { is_expected.to redirect_to(login_url) }
    end

    context 'when user is logged in' do
      let!(:user) { FactoryGirl.create(:user) }
      before do
        session[:user_id] = user.id
        get :index
      end

      it { is_expected.to render_template('index') }
    end
  end

  describe "GET #new" do
    before { get :new }

    # assigns test instance var of object
    it { expect(assigns(:user)).to be_a_new(User) }
    it { should respond_with(:success) }
    it { should render_template('new') }
  end

  describe 'GET #show' do
    let!(:user) { FactoryGirl.create(:user, id: 1) }
    
    before { get :show, id: user.id }

    it { should route(:get, user_path(user.id)).to(action: :show, id: user.id) }
    it { should respond_with(:success) }
    it { should render_template('show') }
  end

  describe 'GET #edit' do
    it { should use_before_action(:logged_in_user) }
    let!(:user) { FactoryGirl.create(:user, id: 1) }

    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
        get :edit, id: user.id
      end

      it { should route(:get, edit_user_path(user.id)).to(action: :edit, id: user.id) }
      it { should render_template('edit') }
    end

    context 'when user is not logged in' do
      before { get :edit, id: user.id }

      it { is_expected.to set_flash[:danger] }
      it { is_expected.to redirect_to login_url }
    end
  end

  describe 'POST #create' do
    context 'when user sends valid form' do
      let!(:user) { FactoryGirl.build(:user) }
      before do
        allow(User).to receive(:new) { user }
        post :create, user: user.attributes
      end

      it { expect(assigns(:user)).to eq(user) }
      it { expect(user.save).to be true }
      it { should set_flash[:success] }
      it { should redirect_to user }
    end

    context 'when user sends invalid form' do
      before do
        allow(controller).to receive(:user_params) { FactoryGirl.attributes_for(:user, name: '') }
        post :create
      end

      it { should render_template('new') }
    end
  end

  describe 'PATCH #update' do
    
    let!(:user) { FactoryGirl.create(:user) }
    it { should use_before_action(:logged_in_user) }

    before { session[:user_id] = user.id }

    context 'when the update is successful' do
      before { put :update, id: user.id, user: { email: 'new_email@sample.com' } }

      it { expect(user.reload.email).to eq 'new_email@sample.com' }
      it { should set_flash[:success] }
      it { should redirect_to user }
    end

    context 'when the update is fail' do
      before { put :update, id: user.id, user: { name: '' } }

      it { should render_template('edit') }
    end
  end

  describe '#user_params' do
    let(:params) { { user: FactoryGirl.attributes_for(:user) } }

    it { should permit(:name, :email, :password, :password_confirmation)
                  .for(:create, params: params)
                  .on(:user) }
  end

end