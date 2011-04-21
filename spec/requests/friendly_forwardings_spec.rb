require 'spec_helper'

describe "FriendlyForwardings" do
  it 'forwards to the requested page after signin' do
    user = Factory(:user)
    visit edit_user_path(user)
# The test automatically follows the redirect to the signin page.
    fill_in :email,     with: user.email
    fill_in :password,  with: user.password
    click_button
# The smart testing follows the redirect again
    response.should render_template('users/edit')
  end
end
