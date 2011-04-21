require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'new'" do
    before(:each) do 
      get 'new'
    end
    it "should be successful" do
      response.should be_success
    end
    it "should have the right title" do
      response.should have_selector('title', content: "Sign up")
    end
  end

  describe 'SHOW users' do
    before(:each) do 
      @user = Factory(:user)
      get :show, id: @user
    end

    it 'should find the right user' do 
      assigns(:user).should == @user
    end

    it "should have the right title" do
      response.should have_selector('title', content: @user.name)
    end

    it 'should use their name' do 
      response.should have_selector('h1', content: @user.name)
    end
    it  'should have a profile image' do 
      response.should have_selector("h1>img", class: 'gravatar')
    end
  end
  describe "POST 'create'" do 
    def prep
      post :create, user: @attr
    end
    describe 'failure' do 
      before(:each) do 
        @attr = {name: '', email: '', password: '', password_confirmation: '' }
        prep
      end
      it "doesn't create a user" do
        lambda do
          prep
        end.should_not change(User, :count)
      end

      it 'has the right title' do
        response.should have_selector("title", content: "Sign up")
      end

      it "renders the 'new' page" do
        response.should render_template('new')
      end
    end # describe failure
    describe 'success' do 
      it 'creates a user in the database' do
        lambda do
          post :create, user: {name: 'New User', email: 'user@example.com', password: 'foobar', password_confirmation: 'foobar' }
        end.should change(User, :count).by(1)
      end
      describe 'success2' do 
        before(:each) do 
          @attr = {name: 'New User', email: 'user@example.com', password: 'foobar', password_confirmation: 'foobar' }
          prep
        end
        it 'redirects to the user show page' do
          response.should redirect_to(user_path(assigns(:user)))
        end
        it 'has a friendly flash method' do
          flash[:success].should =~ /welcome to the sample app/i
        end
        it 'signs the user in' do
          controller.should be_signed_in
        end
      end # ('success2')
    end #describe success
  end # describe POST 'create'
end

