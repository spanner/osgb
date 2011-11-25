class String
  # Defines a few methods to make the grid reference machinery easily 
  # accessible from string objects.

  # Returns true if the string is a valid grid reference: that is, it consits 
  # of two valid square-designation  letters then 4, 6, 8 or 10 digits. 
  # Invalid, malformed and just plain not a grid reference will all return
  # false.
  #
  def is_gridref?
    !!(self.upcase =~ /^(H(P|T|U|Y|Z)|N(A|B|C|D|F|G|H|J|K|L|M|N|O|R|S|T|U|W|X|Y|Z)|OV|S(C|D|E|G|H|J|K|M|N|O|P|R|S|T|U|W|X|Y|Z)|T(A|F|G|L|M|Q|R|V)){1}\d{4}(NE|NW|SE|SW)?$|((H(P|T|U|Y|Z)|N(A|B|C|D|F|G|H|J|K|L|M|N|O|R|S|T|U|W|X|Y|Z)|OV|S(C|D|E|G|H|J|K|M|N|O|P|R|S|T|U|W|X|Y|Z)|T(A|F|G|L|M|Q|R|V)){1}(\d{4}|\d{6}|\d{8}|\d{10}))$/)
  end

  # Returns true if the string looks like a grid reference, whether or
  # not it is well-formed or valid on the ground. In validation this may allow 
  # you to distinguish between mistaken and irrelevant input.
  #
  # "HD123456".resembles_gridref?       # -> true
  # "HD123456".is_gridref?              # -> false
  # "SD12345".resembles_gridref?        # -> true
  # "SD12345".is_gridref?               # -> false
  # "WC1 1AA".resembles_gridref?        # -> false
  #
  def resembles_gridref?
    !!(self.upcase =~ /^\w\w\d{2,}/)
  end

  # Returns true if the string can be decomposed into a valid lat/long 
  # co-ordinate pair.
  #
  def is_latlng?
    coordinates && coordinates.valid?
  end

  # Returns true if the string can be decomposed into a co-ordinate pair,
  # regardless of whether the coordinates are valid.
  #
  def resembles_latlng?
    !!coordinates
  end

  # Treats the string as a coordinate pair, if that can be done. Any two
  # decimal numbers, positive or negative, separated by any non-digit (and 
  # non -) characters are acceptable.
  #
  #     "54.196763, -3.093320".coordinates      # -> [54.196763, -3.093320]
  #
  def coordinates(datum=:osgb36, options={})
    if matches = self.match(/(-?\d+\.\d+)[^\d\-]+(-?\d+\.\d+)/)
      lat,lng = matches[1,2]
      Osgb::Point.new(lat, lng, datum, options[:precision])
    else
      nil
    end
  end

  # If the string is a valid grid reference, this returns the lat/long point 
  # using the specified or default datum. Default is WGS84 for GPS compatibility.
  #
  def to_latlng(options={})
    if is_gridref?
      Osgb::Gridref.new(self, options).to_latlng(options[:datum])
    else
      self.coordinates(options[:datum])
    end
  end
  
  # Returns the grid reference as a lat/long pair on the specified or default datum, 
  # raising an exception if it is not valid.
  #
  def to_latlng!(options={})
    with_validity_check { to_latlng(options) }
  end
  
  # If the string is a valid grid reference, this returns the coordinate pair 
  # using the OSGB36 datum, which is the native representation for grid references.
  #
  def to_osgb36(options={})
    if is_gridref?
      Osgb::Gridref.new(self, options).to_latlng(:osgb36)
    else
      self.coordinates(:osgb36, options)
    end
  end

  # Returns the grid reference as a lat/long pair on OSGB36, raising an exception
  # if it is not valid.
  #
  def to_osgb36!(options={})
    with_validity_check { to_osgb36(options) }
  end

  # If the string is a valid grid reference, this returns the coordinate pair 
  # using the WGS84 datum, which is the most suitable representation for work
  # with GPS or google maps.
  #
  def to_wgs84(options={})
    if is_gridref?
      Osgb::Gridref.new(self, options).to_latlng(:wgs84)
    else
      self.coordinates(:wgs84, options)
    end
  end
  
  # Returns the grid reference as a lat/long pair on WGS84, raising an exception
  # if it is not valid.
  #
  def to_wgs84!(options={})
    with_validity_check { to_wgs84(options) }
  end

  # Returns the latitude component of the string, however it can be found. Works 
  # for both coordinate pairs and grid references. Defaults to WGS84 if coming from 
  # a grid reference.
  #
  def lat(options={})
    to_latlng(options).lat
  end
  
  # Returns the longitude component of the string, however it can be found. Works 
  # for both coordinate pairs and grid references. Defaults to WGS84 if coming from 
  # a grid reference.
  #
  def lng(options={})
    to_latlng(options).lng
  end 
  
protected

  def with_validity_check(&block)
    raise Osgb::TransformationError unless is_gridref?
    block.call
  end

end
