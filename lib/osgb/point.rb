module Osgb
  class Point
    # A coordinate pair on a specified ellipsoid, 
    # easy to use either in string or array context
    # and able to perform basic distance and equivalence. 
    # calculations.
    
    attr_writer :lat, :lng
    attr_accessor :datum, :precision
    
    # Usage: 
    #     Osgb::Point.new(lat[float], lng[float], datum[symbol], precision[integer])
    #
    # Default datum is :osgb36. For most web use you will be using WGS84 points, since
    # that's the standard for most GPS applications and used by google maps:
    #
    #    Osgb::Point.new(54.196915, -3.094684, :wgs84)
    #    Osgb::Point.new(54.196763, -3.093320).transform_to(:wgs84)
    #
    def initialize(lat, lng, datum=nil, precision=nil)
      @lat = lat.to_f
      @lng = lng.to_f
      @datum = datum || :osgb36
      @precision = precision || 6
    end
    
    # Returns the latitude of the point, rounded to the specified precision
    #
    def lat
      round(@lat)
    end
    
    # Returns the longitude of the point, rounded to the specified precision
    #
    def lng
      round(@lng)
    end
    
    # Returns true if the coordinates are both specified and within the acceptable range.
    #
    def valid?
      lat && lng && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180
    end
    
    # Returns the point as a "lat,lng" string.
    def to_s
      "#{lat},#{lng}"
    end
    
    # Returns the point as a [lat,lng] array.
    def to_a
      [lat, lng]
    end
    
    # Remaps the point onto another datum. If you're turning OS grid references into GPS coordinates you 
    # have to remap from OSGB36 to WGS84:
    #
    #    point = "SD28687846".to_latlng.transform_to(:wgs84)
    #
    # or more concisely:
    #
    #    point = "SD28687846".to_wgs84
    #
    def transform_to(target_datum)
      return self if datum == target_datum
      if helmert = Osgb::Helmert[:"#{self.datum}_to_#{target_datum}"]
        cartesian_coordinates = Osgb::Ellipsoid[self.datum].polar_to_cartesian(@lat.to_radians,@lng.to_radians)
        transformed = helmert.transform(*cartesian_coordinates)
        phi, lambda = Osgb::Ellipsoid[target_datum].cartesian_to_polar(*transformed)
        self.class.new(phi.to_degrees, lambda.to_degrees, target_datum, precision)
      else
        raise Osgb::TransformationError, "Missing helmert transformation for #{self.datum} to #{target_datum}"
      end
    end

    # Tests the equivalence of two points, however they are specified. 
    # If given two Point objects, they can lie on different datums:
    #
    #    Osgb::Point.new(54.196763, -3.093320, :osgb36) == Osgb::Point.new(54.196915, -3.094684, :wgs84)  # -> true
    #
    # When comparing a point with a string or array representation they are assumed 
    # to lie on the same datum:
    #
    #    Osgb::Point.new(54.196763, -3.093320) == "54.196763, -3.093320"   # -> true
    #    Osgb::Point.new(54.196763, -3.093320) == [54.196763, -3.093320]   # -> true
    #    Osgb::Point.new(54.196763, -3.093320) == "SD28687846"             # -> true
    #
    # Two points with different precisions will not be considered equivalent.
    #
    def ==(other)
      case other
      when Osgb::Point
        other = other.transform_to(self.datum) unless other.datum == self.datum
        self.lat == other.lat && self.lng == other.lng && self.datum == other.datum
      when Array
        self.to_a == other
      when String
        self == other.to_latlng(:datum => self.datum) # serves to normalise string representation
      end
    end

  private
  
    def round(value) #:nodoc:
      if value.method(:round).arity == 0
        multiplier = 10**precision
        (value * multiplier).round.to_f / multiplier
      else
        value.round(precision)
      end
    end
  
  end
end