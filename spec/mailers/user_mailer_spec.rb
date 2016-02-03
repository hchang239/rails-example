require "rails_helper"

RSpec.describe UserMailer, type: :mailer do

  let!(:user) { FactoryGirl.create(:user) }

  describe "account_activation" do
    let(:mail) { UserMailer.account_activation(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Account Activation")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["noreply@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include(user.activation_token)
      expect(mail.body.encoded).to include(CGI::escape(user.email))
    end
  end

  describe "password_reset" do
    before { user.reset_token = User.new_token }
    let(:mail) { UserMailer.password_reset(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Password Reset")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["noreply@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include(user.reset_token)
      expect(mail.body.encoded).to include(CGI::escape(user.email))
    end
  end

end
