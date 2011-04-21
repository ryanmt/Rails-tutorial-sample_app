require 'spec_helper'

describe "Users" do
  describe 'signup' do
    describe 'success' do 
      it "makes a new user" do
        lambda do
          visit signup_path
          fill_in "Name",                   with: 'Ex User'
          fill_in "Email",                  with: 'user@example.com'
          fill_in "Password",               with: 'foobar'
          fill_in "Confirm your password",  with: 'foobar'
          click_button
          response.should render_template('users/show')
          response.should have_selector("div.flash.success", content: 'Welcome')
        end.should change(User, :count).by(1)
      end # new user
    end # success
    describe 'failure' do
      it "can't make a new user" do
        lambda do
          visit signup_path
          fill_in "Name",                       with: ''
          fill_in "Email",                      with: ''
          fill_in "Password",                   with: ''
          fill_in "Confirm your password",      with: ''
          click_button
          response.should render_template('users/new')
          response.should have_selector("div#error_explanation")
        end.should_not change(User, :count)
      end
    end #failure
  end # signup
  describe 'log in/out' do 
    describe 'failure' do
      it "doesn't sign a user in" do 
        visit login_path
        fill_in :email,     with: ''
        fill_in :password,  with: ''
        click_button
        response.should have_selector('div.flash.error', content: 'Invalid')
      end
    end #failure
    describe 'success' do
      it 'should sign a user in and out' do 
        user = Factory(:user)
        visit login_path
        fill_in :email,     with: user.email
        fill_in :password,  with: user.password
        click_button
        controller.should be_signed_in
        click_link 'Log out'
        controller.should_not be_signed_in
      end
    end #success
  end # log in/out
end
