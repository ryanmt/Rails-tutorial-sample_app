require 'spec_helper'

describe MicropostsController do
  render_views

  describe 'access control' do
    it 'denies access to create' do
      post :create
      response.should redirect_to(login_path)
    end
    it 'denies access to destroy' do 
      delete :destroy, id: 1
      response.should redirect_to(login_path)
    end
  end #access control
  describe "POST 'create'" do 
    before(:each) do 
      @user = test_sign_in(Factory :user)
    end
    describe 'failure' do 
      before(:each) do 
        @attr = { content: '' }
      end
      it "doesn't create a micropost" do 
        lambda do 
          post :create, micropost: @attr
        end.should_not change(Micropost, :count)
      end
      it 'renders the home page' do 
        post :create, micropost: @attr
        response.should render_template('pages/home')
      end
    end #failure
    describe 'success' do 
      before :each do
        @attr = { content: 'Lorem ipsum' }
      end
      it 'creates a micropost' do 
        lambda do 
          post :create, micropost: @attr
        end.should change(Micropost, :count)
      end
      it 'redirects to the home page' do
        post :create, micropost: @attr
        response.should redirect_to(root_path)
      end
      it 'flashes the success message' do 
        post :create, micropost: @attr
        flash[:success].should =~ /micropost created/i
      end
    end # success'
  end # POST create
  describe "DELETE 'destroy'" do 
    describe ' An unauthorized user' do 
      before :each do 
        @user = Factory(:user)
        wrong_user = Factory(:user, email: Factory.next(:email))
        test_sign_in(wrong_user)
        @micropost = Factory(:micropost, user: @user)
      end
      it 'denies access' do 
        delete :destroy, id: @micropost
        response.should redirect_to(root_path)
      end
    end

    describe 'An authorized user' do 
      before :each do 
        @user = test_sign_in(Factory(:user))
        @micropost = Factory(:micropost, user: @user)
      end

      it 'destroys the micropost' do 
        lambda do 
          delete :destroy, id: @micropost
        end.should change(Micropost, :count).by(-1)
      end 
    end # Authorized user
  end # DELETE destroy micropost
end
