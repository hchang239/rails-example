require 'rails_helper'

# let vs. let!
#   - with 'let' the variable is created when it is called in a test (lazily created)
#   - 'let!' creates the variables immediately

RSpec.describe ApplicationHelper, type: :helper do
  describe "generates full_title for title of each page" do
    let(:base_title) { "My Rails Sample App" }

    context "if page_title is empty" do
      subject { helper.full_title }
      it { is_expected.to eq(base_title) }
    end

    context "if page_title is not empty" do
      subject { helper.full_title("TestHeader") }
      it { is_expected.to eq("TestHeader" + ' | ' + base_title) }
    end
  end
end
