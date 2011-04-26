require 'spec_helper'

describe RelationshipsController do 
  describe 'access control' do 
    it 'requires a log in for creation' do 
      post :create
      response.should redirect_to(login_path)
    end
    it 'requires logged in for destroy' do 
      delete :destroy, id: 1
      response.should redirect_to(login_path)
    end
  end # Access Control
  describe "POST 'create'" do 
    before :each do 
      @user = test_sign_in(Factory(:user))
      @followed = Factory(:user, email: Factory.next(:email))
    end
    it 'creates a relationship' do 
      lambda do 
        post :create, relationship: { followed_id: @followed }
        response.should be_redirect
      end.should change(Relationship, :count).by(1)
    end
    it 'creates a relationship with AJAX' do 
      lambda do 
        xhr :post, :create, relationship: { followed_id: @followed }
        response.should be_success
      end.should change(Relationship, :count).by(1)
    end
  end # POST create
  describe "DELETE 'destroy'" do 
    before :each do 
      @user = test_sign_in(Factory(:user))
      @followed = Factory(:user, email: Factory.next(:email))
      @user.follow!(@followed)
      @relationship = @user.relationships.find_by_followed_id(@followed)
    end
    it 'destroys a relationship' do 
      lambda do 
        delete :destroy, id: @relationship
        response.should be_redirect
      end.should change(Relationship, :count).by(-1)
    end
    it 'destroys with AJAX' do 
      lambda do 
        xhr :delete, :destroy, id: @relationship
        response.should be_success
      end.should change(Relationship, :count).by(-1)
    end
  end # DELETE 'destroy'
end
