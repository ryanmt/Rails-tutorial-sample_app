require 'spec_helper'

describe User do
  before(:each) do 
    @attr = {name: "Mr Jones", email: 'user@example.com', password: 'foobar', password_confirmation: 'foobar'}
  end
  
  it 'should create a new instance given valid attributes' do
    User.create!(@attr)
  end

  it 'should require a name' do 
    no_name = User.create(@attr.merge(name: ""))
    no_name.should_not be_valid
  end
  
  it 'should reject absurdly long names' do
    long_name = "a"*50
    long_user = User.new(@attr.merge(name: long_name))
    long_user.should_not be_valid
  end
  describe 'Check the email stuff for validity and uniqueness' do 
    it 'should require a valid email address' do 
      valid_addresses = %w[user@foo.com THE_USER@foo.bar.org first.last+hello@foo.jp]
      valid_addresses.each do |address|
        valid_email = User.new(@attr.merge(email: address))
        valid_email.should be_valid
      end
      flawed_addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      flawed_addresses.each do |address|
        flawed_email = User.create(@attr.merge(email: address))
        flawed_email.should_not be_valid
      end
    end
    it 'should reject a duplicate email address' do
      User.create!(@attr)
      user_dup = User.new(@attr)
      user_dup.should_not be_valid
    end
    it 'should reject duplicates, regardless of case differences' do
      upcased_email = @attr[:email].upcase
      User.create!(@attr.merge(:email => upcased_email))
      user_dup = User.new(@attr)
      user_dup.should_not be_valid
    end
  end #email validity/ uniqueness
  describe 'Password verifications' do 
    it 'requires a password' do
      User.new(@attr.merge(password: "", password_confirmation: "")).should_not be_valid
    end
    it 'requires a matching password confirmation' do
      User.new(@attr.merge(password_confirmation: "")).should_not be_valid
    end
    it 'rejects short passwords' do
      short = 'a'*5
      User.new(@attr.merge(password: short, password_confirmation: short)).should_not be_valid
    end
    it 'rejects long passwords' do 
      long = 'a'*41
      User.new(@attr.merge(password: long, password_confirmation: long)).should_not be_valid
    end
  end #password verifications
  describe "Password encrytion" do
    before(:each) do
      @user = User.create!(@attr)
    end
    it 'has an encrypted password attribute' do
      @user.should respond_to(:encrypted_password)
    end
    it 'sets the encrypted password' do 
      @user.encrypted_password.should_not be_blank
    end
  end # password encryption
  describe 'has_password? method' do
    before(:each) do 
      @user = User.create!(@attr)
      raise "User didn't create" if @user.nil?
    end
    it 'returns true if the passwords match' do 
      @user.has_password?(@attr[:password]).should be_true
    end
    it 'should be false if the passwords dont match' do 
      @user.has_password?("invalid").should be_false
    end
  end # has password?
  describe 'authenticate method' do 
    it 'should return nil on email/password mismatch' do 
      wrong_password = User.authenticate(@attr[:email], "wrongpass")
      wrong_password.should be_nil
    end
    it 'returns nil for an email address with no user' do
      nonexistant_user = User.authenticate('bar@foo.com', @attr[:password])
      nonexistant_user.should be_nil
    end
    it 'returns the user on email/password match' do 
      matching_user = User.authenticate(@attr[:email], @attr[:password])
      matching_user.should == @user
    end
  end # authentication
  describe 'administrator' do
    before(:each) do 
      @user = User.create(@attr)
    end
    it 'responds to admin' do 
      @user.should respond_to(:admin)
    end
    it "isn't an admin by default" do 
      @user.should_not be_admin
    end
    it 'can become an admin' do 
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end # administrator
  describe 'micropost associations' do 
    before :each do 
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, user: @user, created_at: 1.day.ago)
      @mp2 = Factory(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it 'has a microposts attribute' do 
      @user.should respond_to(:microposts)
    end

    it 'sorts the microposts array in reverse time order' do 
      @user.microposts.should == [@mp2, @mp1]
    end
    it 'destroys the associated microposts when destroyed' do 
      @user.destroy
      [@mp1, @mp2].each do |mp|
        Micropost.find_by_id(mp.id).should be_nil
      end
    end
    describe 'status feed' do
      it 'has a feed' do 
        @user.should respond_to(:feed)
      end

      it "includes user's microposts" do 
        @user.feed.include?(@mp1).should be_true
        @user.feed.include?(@mp2).should be_true
      end

      it "doesn't have other's microposts" do 
        mp3 = Factory(:micropost, user: Factory(:user, email: Factory.next(:email)))
        @user.feed.include?(mp3).should be_false
      end
    end # status feed
  end # micropost associations
end
