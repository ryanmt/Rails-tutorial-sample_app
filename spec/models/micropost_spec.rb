require 'spec_helper'

describe Micropost do
  before(:each) do 
    @user = Factory(:user)
    @attr = { content: 'value for content'}
  end

  it 'creates a new instance with the valid attributes' do 
    @user.microposts.create!(@attr)
  end
  
  describe 'user associations' do 
    before :each do 
      @micropost = @user.microposts.create(@attr)
    end
    it 'has a user attribute' do 
      @micropost.should respond_to(:user)
    end

    it 'has the right user associated' do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
  end # user associations
  describe 'validations' do 
    it 'requires an user id' do 
      Micropost.new(@attr).should_not be_valid
    end
    it 'requires nonblank content' do 
      @user.microposts.build(content: '   ').should_not be_valid
    end
    it 'rejects long content' do 
      @user.microposts.build(content: "a"*141).should_not be_valid
    end
  end # Validations
  describe 'from_users_followed_by' do 
    before :each do 
      @other_user = Factory(:user, email: Factory.next(:email))
      @third_user = Factory(:user, email: Factory.next(:email))
      @user_post = @user.microposts.create!(content: 'foo')
      @other_post = @other_user.microposts.create!(content: 'bar')
      @third_post = @third_user.microposts.create!(content: 'baz')
      @user.follow!(@other_user)
    end
    it 'has the method' do 
      Micropost.should respond_to(:from_users_followed_by)
    end
    it "includes the followed user's microposts" do 
      Micropost.from_users_followed_by(@user).should include(@other_post)
    end
    it 'includes the user\'s microposts' do 
      Micropost.from_users_followed_by(@user).should include(@user_post)
    end
    it 'doesn\'t include the unfollowed user\'s posts' do 
      Micropost.from_users_followed_by(@user).should_not include(@third_post)
    end
  end # from_users_followed_by
end
