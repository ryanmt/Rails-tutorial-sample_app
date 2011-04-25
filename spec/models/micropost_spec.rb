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
end
