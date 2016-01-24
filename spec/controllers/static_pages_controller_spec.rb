require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do

  it { should route(:get, '/').to(action: :home) }
  it { should route(:get, 'help').to(action: :help) }
  it { should route(:get, 'about').to(action: :about) }
  it { should route(:get, 'contact').to(action: :contact) }

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

  describe "GET #contact" do
    before { get :contact }

    it { should respond_with(:success) }
    it { should render_template('contact') }
  end

end
