require 'spec_helper'

describe String do
  it "should know whether or not it looks like a grid reference" do
    "SD13241324".is_gridref?.should be_true
    "catapult".is_gridref?.should be_false
    "54.196915 -3.094684".is_gridref?.should be_false
  end

  it "should know whether or not it looks like a lat/lng pair" do
    "SD13241324".is_latlng?.should be_false
    "catapult".is_latlng?.should be_false
    "54.196915 -3.094684".is_latlng?.should be_true
    "54.196915, -3.094684".is_latlng?.should be_true
  end

  it "should turn be able to turn itself into an osgb lat/lng pair" do
    "SD28687846".to_latlng(:precision => 6).should == [54.196763, -3.093320]
    "SD28687846".to_latlng(:precision => 2).should == [54.2, -3.09]
  end

  it "should turn be able to turn itself into a wgs84 lat/lng pair for gps use" do
    "SD28687846".to_wgs84(:precision => 6).should == [54.196915, -3.094684]
    "SD28687846".to_wgs84(:precision => 2).should == [54.2, -3.09]
  end
end
