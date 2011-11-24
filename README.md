= OSGB

Wiki[https://github.com/spanner/osgb/wiki] RDocs[http://rdoc.info/projects/spanner/osgb]

Osgb is a library that converts between British (and Irish) grid references and latitude and longitude co-ordinates. It is precise to about 5m, which is to say it's good enough for WGS84 and most GPS use but not local enough for surveying to ETRS89.

== Installation

In <b>Rails 3</b>, add this to your Gemfile and run +bundle install+.

  gem "osgb"

In <b>Rails 2</b>, add this to your environment.rb file.

  config.gem "osgb"

Alternatively, you can install it as a plugin.

  rails plugin install git://github.com/spanner/osgb.git

== Usage

You don't need to make any explicit reference to the gem. It adds conversion methods to the String class:

    "SD12341234".is_gridref?                # -> true
    "SD12341234".to_latlng                  # -> 
    "SD12341234".to_WGS84                   # -> 
    "1.056789, 55.98978607".is_latlng?      # -> true
    "1.056789, 55.98978607".to_gridref      # -> true

and provides some help for your ActiveRecord classes:

    class Checkpoint < ActiveRecord::Base
      has_gridref :lat => 'lat', 
                  :lng => 'lng', 
                  :gridref => 'gridref',
                  :validation => false,
                  :converstion => true

The :lat, :lng and :gridref keys should pass in the names of the relevant columns if they don't match these defaults. 

== Questions or Problems?

If you have any issues with CanCan which you cannot find the solution to in the documentation[https://github.com/ryanb/cancan/wiki], please add an {issue on GitHub}[https://github.com/ryanb/cancan/issues] or fork the project and send a pull request.

To get the specs running you should call +bundle+ and then +rake+. See the {spec/README}[https://github.com/ryanb/cancan/blob/master/spec/README.rdoc] for more information.


== Special Thanks

CanCan was inspired by declarative_authorization[https://github.com/stffn/declarative_authorization/] and aegis[https://github.com/makandra/aegis]. Also many thanks to the CanCan contributors[https://github.com/ryanb/cancan/contributors]. See the CHANGELOG[https://github.com/ryanb/cancan/blob/master/CHANGELOG.rdoc] for the full list.
