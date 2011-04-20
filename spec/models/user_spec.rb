require 'spec_helper'

describe User do
  before(:each) do 
    @attr = {name: "Mr Jones", email: 'user@example.com'}
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
end

