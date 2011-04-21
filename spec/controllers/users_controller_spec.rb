require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
    it "should have the right title" do
      get 'new'
      response.should have_selector('title', content: "Sign up")
    end
  end

  describe 'SHOW users' do
    before(:each) do 
      @user = Factory(:user)
    end

    it 'should find the right user' do 
      get :show, :id => @user
      assigns(:user).should == @user
    end

    it "should have the right title" do
      get :show, id: @user
      response.should have_selector('title', content: @user.name)
    end

    it 'should use their name' do 
      get :show, id: @user
      response.should have_selector('h1', content: @user.name)
    end
    it  'should have a profile image' do 
      get :show, id: @user
      response.should have_selector("h1>img", class: 'gravatar')
    end
  end
  describe "POST 'create'" do 
    describe 'failure' do 
      before(:each) do 
        @attr = {name: '', email: '', password: '', password_confirmation: '' }
      end
      it "doesn't create a user" do
        lambda do
          post :create, user: @attr
        end.should_not change(User, :count)
      end

      it 'has the right title' do
       post :create, user: @attr
       response.should have_selector("title", content: "Sign up")
      end

      it "renders the 'new' page" do
        post :create, user: @attr
        response.should render_template('new')
      end
    end # describe failure
    describe 'success' do 
      before(:each) do 
        @attr = {name: 'New User', email: 'user@example.com', password: 'foobar', password_confirmation: 'foobar' }
      end
      it 'creates a user in the database' do
        lambda do
          post :create, user: @attr
        end.should change(User, :count).by(1)
      end
      it 'redirects to the user show page' do
        post :create, user: @attr
        response.should redirect_to(user_path(assigns(:user)))
      end
      it 'has a friendly flash method' do
        post :create, user: @attr
        flash[:success].should =~ /welcome to the sample app/i
      end
    end #describe success
  end # describe POST 'create'
end

