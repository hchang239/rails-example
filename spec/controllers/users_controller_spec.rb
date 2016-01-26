require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  it { should route(:get, signup_path).to(action: :new) }
  it { should route(:post, users_path).to(action: :create) }

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

  describe 'permit user_params and successful creation' do
    let(:params) { { user: FactoryGirl.attributes_for(:user) } }

    it { should permit(:name, :email, :password, :password_confirmation)
                  .for(:create, params: params)
                  .on(:user) }
  end

  context 'when user sends invalid form' do
    before do
      allow(controller).to receive(:user_params) { FactoryGirl.attributes_for(:user, name: '') }
      post :create
    end

    it { should render_template('new') }
  end

end