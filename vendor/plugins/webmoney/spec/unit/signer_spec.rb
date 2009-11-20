require File.dirname(__FILE__) + '/../spec_helper'

describe Signer, "class" do

  before(:each) do                                                                                                   
    @s = Signer.new( WmConfig.wmid, WmConfig.password, WmConfig.key)                                                                                             
  end

  it "should be Signer class" do
    @s.should be_kind_of(Signer)
  end
  
  it "should signing string" do
    @s.sign('Test123').should_not be_nil
    @s.sign('Test123').should match(/[0-9a-f]{132}/)
  end
  
  it "should signing empty string" do
    @s.sign('').should match(/[0-9a-f]{132}/)
  end
  
  it "should raise error on nil string" do
    lambda{@s.sign(nil)}.should raise_error(ArgumentError)
  end
  
  it "should raise error on nil pass" do
    lambda{Signer.new('405424574082', nil, '')}.should raise_error(ArgumentError)
  end
  
  it "should raise error on blank key" do
    lambda{Signer.new('405424574082', 'test', nil)}.should raise_error(ArgumentError)
    lambda{Signer.new('405424574082', 'test', '')}.should raise_error(ArgumentError)
  end
  
end