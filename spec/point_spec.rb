require 'spec_helper'

describe Osgb::Point do
  
  let(:osgb) { Osgb::Point.new(54.196763, -3.093320, :osgb36) }
  let(:wgs) { Osgb::Point.new(54.196915, -3.094684, :wgs84) }
  
  it "should have lat and long" do
    wgs.lat.should == 54.196915
    wgs.lng.should == -3.094684
  end
  
  it "should be good at equality" do
    (wgs == [54.196915, -3.094684]).should be_true
    (wgs == "54.196915,-3.094684").should be_true
    (wgs == "54.196915,  -3.094684").should be_true
    (wgs == "SD28687846").should be_true
    (wgs == "SD13241324").should be_false
    (wgs == osgb).should be_true
    (wgs == Osgb::Point.new(54.196914, -3.094684)).should be_false
  end
  
  it "should be good at helmert transformations" do
    osgb.transform_to(:wgs84).should == wgs
  end
end
