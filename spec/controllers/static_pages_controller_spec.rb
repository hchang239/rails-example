require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do

  it { should route(:get, 'static_pages/home').to(action: :home) }
  it { should route(:get, 'static_pages/help').to(action: :help) }
  it { should route(:get, 'static_pages/about').to(action: :about) }

  describe "GET #home" do
    before { get :home }

    it { should respond_with(:success) }
    it { should render_template('home') }
  end

  describe "GET #help" do
    before { get :help }

    it { should respond_with(:success) }
    it { should render_template('help') }
  end

  describe "GET #about" do
    before { get :about }

    it { should respond_with(:success) }
    it { should render_template('about') }
  end

end
