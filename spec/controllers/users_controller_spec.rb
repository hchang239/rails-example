require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  it { should route(:get, 'signup').to(action: :new) }

  describe "GET #new" do
    before { get :new }

    it { should respond_with(:success) }
    it { should render_template('new') }
  end

end
