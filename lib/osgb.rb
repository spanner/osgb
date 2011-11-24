require 'osgb/angle_conversions'              # converts degrees to radians and back again
require 'osgb/ellipsoid'                      # standard approximations to the squashed-circle shape of the earth
require 'osgb/projection'                     # the geometrical distortions required by a map projection
require 'osgb/helmert'                        # 3d transformation algorithm for mapping between cartesian and ellipsoidal polar coordinates
require 'osgb/gridref'                        # parse grid references and returns lat/long pairs
require 'osgb/string_conversions'             # add conversion methods to String
require 'osgb/railtie' if defined? Rails      # add useful methods to ActiveRecord

# Define standard ellipsoids

Osgb::Ellipsoid.new :osgb36, 6377563.396, 6356256.910
Osgb::Ellipsoid.new :wgs84, 6378137.000, 6356752.3141
Osgb::Ellipsoid.new :ie65, 6377340.189, 6356034.447
Osgb::Ellipsoid.new :utm, 6378388.000, 6356911.946

# Define standard projections

Osgb::Projection.new :gb, :scale => 0.9996012717, :phi0 => 49, :lambda0 => -2, :e0 => 400000, :n0 => -100000, :ellipsoid => :osgb36
Osgb::Projection.new :ie, :scale => 1.000035, :phi0 => 53.5, :lambda0 => -8, :e0 => 250000, :n0 => 250000, :ellipsoid => :ie65
Osgb::Projection.new :utm29, :scale => 0.9996, :phi0 => 0, :lambda0 => -9, :e0 => 500000, :n0 => 0, :ellipsoid => :utm
Osgb::Projection.new :utm30, :scale => 0.9996, :phi0 => 0, :lambda0 => -3, :e0 => 500000, :n0 => 0, :ellipsoid => :utm
Osgb::Projection.new :utm31, :scale => 0.9996, :phi0 => 0, :lambda0 => 3, :e0 => 500000, :n0 => 0, :ellipsoid => :utm

# the Helmert matrix used to translate to wgs84.

Osgb::Helmert.new :wgs84, :tx => 446.448, :ty => -125.157, :tz => 542.060, :rx => 0.1502, :ry => 0.2470, :rz => 0.8421, :s => -20.4894
