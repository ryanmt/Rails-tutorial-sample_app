require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'new'" do
    it 'works' do
      get :new
      response.should be_success
    end

    it 'has a correct title' do
      get :new
      response.should have_selector('title', content: 'Log in')
    end
  end # describe GET new
  describe "POST 'create'" do
    describe 'invalid login' do
      before(:each) do
        @attr = { email: 'email@example.com', password: 'invalid'}
      end
      it 're-renders the new page' do
        post :create, session: @attr
        response.should render_template('new')
      end
      it 'has the right title' do
        post :create, session: @attr
        response.should have_selector('title', content: 'Log in')
      end
      it 'flash.now error messages you' do
        post :create, session: @attr
        flash.now[:error].should =~ /invalid/i
      end
    end #invalid login
    describe 'successful login' do
      before(:each) do 
        @user = Factory(:user)
        @attr = {email: @user.email, password: @user.password }
      end
      it 'logs the user in' do 
        post :create, session: @attr
        controller.current_user.should == @user
        controller.should be_signed_in
      end
      it 'renders the user "show" page' do
        post :create, session: @attr
        response.should redirect_to(user_path(@user))
      end
      it 'flash.now successful messages the user' do
      end
    end #successful login
  end #POST create
  describe 'DELETE "destroy"' do
    it 'signs the user out' do 
      test_sign_in(Factory(:user))
      delete :destroy
      controller.should_not be_signed_in
      response.should redirect_to(root_path)
    end
  end # DELETE destroy
end
