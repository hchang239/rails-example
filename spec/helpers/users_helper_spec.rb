require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the UsersHelper. For example:
#
# describe UsersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe UsersHelper, type: :helper do
  describe "generate image_tag with user's gravatar" do
    let(:user) { FactoryGirl.create(:user) }
    let(:gravatar_id) { Digest::MD5::hexdigest(user.email.downcase) }
    let(:gravatar_url) { "https://secure.gravatar.com/avatar/#{gravatar_id}" }
    subject { helper.gravatar_for(user) }

    it { is_expected.to eq(image_tag(gravatar_url, alt: user.name, class: 'gravatar')) }
  end
end
