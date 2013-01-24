# OSGB

This is a library that converts between British (and Irish) grid references and latitude and longitude co-ordinates. It is theoretically accurate to about 1m, but realistically you can expect precision of about 10m. Good for google map and GPS use, not recommended for surveying nuclear power plants. I don't suppose people often use grid references for that.

## Installation

In <b>Rails 3</b>, add this to your Gemfile and run `bundle install`.

    gem "osgb"

In <b>Rails 2</b>, add this to your environment.rb file.

    config.gem "osgb"

Alternatively, you can install it as a plugin.

    rails plugin install git://github.com/spanner/osgb.git

## Status

Early days: activerecord interface hasn't settled down, some refactoring likely, bugs entirely possible. The basic algorithms are ancient and sound, though.

## Usage

You don't need to make any explicit reference to the gem. It adds conversion and utility methods to the String class:

    "SD28687846".is_gridref?                # -> true
    "SD28687846".to_latlng                  # -> [54.196915, -3.094684]
    "SD28687846".to_wgs84                   # -> [54.196915, -3.094684]
    "SD28687846".to_osgb36                  # -> [54.196763, -3.093320]
    "1.056789, 55.98978607".is_latlng?      # -> true
    
There is a Point class that's quite useful for geodetic calculations, and we provides some (tentative) help for your ActiveRecord classes:

    class Checkpoint < ActiveRecord::Base
      has_gridref :lat => 'lat', 
                  :lng => 'lng', 
                  :gridref => 'gridref',
                  :validation => false,
                  :converstion => true

The :lat, :lng and :gridref keys should pass in the names of the relevant columns if they don't match these defaults. 

## Geodesy

By default we place our lat/long points on the WGS84 datum, since that's most relevant for online use. You can specify :osgb36 to keep them local:

    "SD28687846".to_latlng(:osgb36)

which involves a bit less processing since that's the datum used by the grid. If you want to use some other datum you will need to define a Helmert transformation from OSGB36 to that ellipsoid.

## Bugs and features

[Github issues](http://github.com/spanner/osgb/issues) please, or for little things an email or github message is fine.

## Author & Copyright

Copyright 2008-2011 Will at spanner.org.

Released under the same terms as Ruby
