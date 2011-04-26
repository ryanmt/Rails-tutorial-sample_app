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

  describe 'GET show users' do
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
    it 'should have a profile image' do 
      response.should have_selector("h1>img", class: 'gravatar')
    end
    it 'shows the microposts' do 
      mp1 = Factory(:micropost, user: @user, content: "foo bar")
      mp2 = Factory(:micropost, user: @user, content: "Baz quux")
      get :show, id: @user
      response.should have_selector('span.content', content: mp1.content)
      response.should have_selector('span.content', content: mp2.content)
    end


  end # GET show users

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
  describe 'GET "edit"' do 
    before(:each) do 
      @user = Factory(:user)
      test_sign_in(@user)
    end
    it 'succeeds' do 
      get :edit, id: @user
      response.should be_success
    end
    it 'has the correct right title' do 
      get :edit, id: @user
      response.should have_selector('title', content: "Edit user")
    end
    it 'has a link to change the Gravatar image' do 
      get :edit, id: @user
      gravatar_url = 'http://gravatar.com/emails'
      response.should have_selector('a', href: gravatar_url, content: 'change')
    end
  end # GET edit
  describe "PUT 'update'" do
    before(:each) do 
      @user = Factory(:user)
      test_sign_in @user
    end
    describe 'failure' do   
      before(:each) do 
         @attr = {email: '', name: '', password: '', password_confirmation: ''}
      end
      it 'renders the "edit" page' do 
        put :update, id: @user, user: @attr
        response.should render_template('edit')
      end
      it 'has the right title' do 
        put :update, id: @user, user: @attr
        response.should have_selector('title', content: "Edit user")
      end
    end  # Failure
    describe 'success' do 
      before(:each) do 
        @attr= {name: "New Name", email: 'user@example.org', password: 'barbaz', password_confirmation: 'barbaz'}
      end
      it 'changes the user attributes' do 
        put :update, id: @user, user: @attr
        @user.reload
        @user.name.should == @attr[:name]
        @user.email.should == @attr[:email]
      end
      it 'redirects to the user show page' do 
        put :update, id: @user, user: @attr
        response.should redirect_to(user_path(@user))
      end
      it 'flashes the success message' do 
        put :update, id: @user, user: @attr
        flash[:success].should =~ /updated/i
      end
    end # Success
  end # "PUT 'update'"
  describe 'authenticate the edit/update pages' do
    before(:each) do 
      @user = Factory(:user)
    end
    describe 'logged out users' do
      it 'denies access to edit' do 
        get :edit, id: @user
        response.should redirect_to(login_path)
      end
      it 'denies access to update' do
        get :update, id: @user, user: {}
        response.should redirect_to(login_path)
      end
    end # Not logged in
    describe 'logged in users' do
      before(:each) do 
        wrong_user = Factory(:user, email: 'user@example.net')
        test_sign_in wrong_user
      end
      it 'requires a matched user to edit' do
        get :edit, id: @user
        response.should redirect_to(root_path)
      end
      it 'requires a matched user to update' do
        put :update, id: @user, user:  {}
        response.should redirect_to(root_path)
      end
    end # Logged in users
  end # authenticate user edits
  describe 'GET "index" of users' do 
    describe 'logged out users' do 
      it 'denies access' do
        get :index
        response.should redirect_to(login_path)
        flash[:notice].should =~ /log in/i
      end
    end #unlogged users
    describe 'logged in users' do 
      before(:each) do 
        @user = test_sign_in(Factory(:user))
        second = Factory(:user, name: "bob", email: 'another@example.com')
        third = Factory(:user, name: "Ben", email: 'another@example.net')
        @users = [@user, second, third]
        30.times do 
          @users << Factory(:user, email: Factory.next(:email))
        end
      end
      it 'succeeds' do 
        get :index
        response.should be_success
      end
      it 'has the right title' do 
        get :index
        @users.each do |user|
          response.should have_selector('li', content: user.name)
        end
      end
      it 'has an element for each user' do
        get :index
        @users[0..2].each do |u|
          response.should have_selector('li', content: u.name)
        end
      end
      it 'paginates the user list' do 
        get :index
        response.should have_selector('div.pagination')
        response.should have_selector('span.disabled', content: "Previous")
        response.should have_selector('a', href: '/users?page=2', content: '2')
        response.should have_selector('a', href: '/users?page=2', content: 'Next')
      end
    end # logged in users
  end # user index
  describe " DELETE 'destroy'" do
    before (:each) do 
      @user = Factory :user
    end
    describe 'not logged in' do 
      it 'denies access' do 
        delete :destroy, id: @user
        response.should redirect_to(login_path)
      end
    end
    describe 'logged in as non-admin' do 
      it 'prohibts deletion' do
        test_sign_in(@user)
        delete :destroy, id: @user
        response.should redirect_to(root_path)
      end
    end
    describe 'logged in as admin' do 
      before(:each) do 
        admin = Factory(:user, email: 'admin@example.com', admin: true)
        test_sign_in(admin)
      end
      it 'destroys the user' do
        lambda do 
          delete :destroy, id: @user
        end.should change(User, :count).by(-1)
      end
      it 'redirects to the users page' do 
        delete :destroy, id: @user
        response.should redirect_to(users_path)
      end
    end # admin logged in
  end # DELETE destroy
  describe 'follow pages' do 
    describe 'not signed in? ' do 
      it 'protects following' do 
        get :following, id: 1
        response.should redirect_to(login_path)
      end
      it 'protects followers' do 
        get :followers, id: 1
        response.should redirect_to(login_path)
      end
    end # Not signed in
    describe 'signed in' do
      before :each do 
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, email: Factory.next(:email))
        @user.follow!(@other_user)
      end
      it 'shows user following' do 
        get :following, id: @user
        response.should have_selector('a', href: user_path(@other_user), content: @other_user.name)
      end
      it 'shows user followers' do 
        get :followers, id: @other_user
        response.should have_selector('a', href: user_path(@user), content: @user.name)
      end
    end # signed in
  end # follow pages
end

