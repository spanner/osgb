require 'spec_helper'

describe String do
  it "should know whether or not it looks like a grid reference" do
    "SD28687846".resembles_gridref?.should be_true
    "SD1324132".resembles_gridref?.should be_true
    "catapult".resembles_gridref?.should be_false
  end

  it "should know whether or not it is a grid reference" do
    "SD28687846".is_gridref?.should be_true
    "SD1324132".is_gridref?.should be_false
    "catapult".is_gridref?.should be_false
    "54.196915 -3.094684".is_gridref?.should be_false
  end

  it "should know whether or not it looks like a lat/lng pair" do
    "SD28687846".resembles_latlng?.should be_false
    "catapult".resembles_latlng?.should be_false
    "54.196915 -3.094684".resembles_latlng?.should be_true
    "54.196915, -3.094684".resembles_latlng?.should be_true
  end

  it "should know whether or not it is a lat/lng pair" do
    "SD28687846".is_latlng?.should be_false
    "catapult".is_latlng?.should be_false
    "54.196915 -3.094684".is_latlng?.should be_true
    "104.196915 -3.094684".is_latlng?.should be_false
    "54.196915 -183.094684".is_latlng?.should be_false
    "54.196915, -3.094684".is_latlng?.should be_true
    "54.196915|-3.094684".is_latlng?.should be_true
    "54.196915:-3.094684".is_latlng?.should be_true
    "54.196915x-3.094684".is_latlng?.should be_true
  end

  it "should turn be able to turn itself into an osgb lat/lng pair" do
    "SD28687846".to_osgb36(:precision => 6).to_a.should == [54.196763, -3.093320]
    "SD28687846".to_osgb36(:precision => 6).to_s.should == "54.196763,-3.09332"
    "SD28687846".to_osgb36(:precision => 2).to_a.should == [54.2, -3.09]
  end

  it "should turn be able to turn itself into a wgs84 lat/lng pair" do
    "SD28687846".to_wgs84(:precision => 6).to_a.should == [54.196915, -3.094684]
    "SD28687846".to_wgs84(:precision => 2).to_a.should == [54.2, -3.09]
  end

  it "should default to WGS84 representation" do
    "SD28687846".to_latlng(:precision => 6).to_a.should == [54.196915, -3.094684]
  end

  it "should blow up if banged" do
    lambda { "SD28687846".to_latlng!(:precision => 6) }.should_not raise_error
    lambda { "SD2868784".to_latlng!(:precision => 6) }.should raise_error(Osgb::TransformationError)
  end
end
