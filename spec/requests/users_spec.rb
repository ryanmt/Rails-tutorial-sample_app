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
end
