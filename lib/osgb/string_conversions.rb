class String
  def is_gridref?
    !!(self.upcase =~ /^(H(P|T|U|Y|Z)|N(A|B|C|D|F|G|H|J|K|L|M|N|O|R|S|T|U|W|X|Y|Z)|OV|S(C|D|E|G|H|J|K|M|N|O|P|R|S|T|U|W|X|Y|Z)|T(A|F|G|L|M|Q|R|V)){1}\d{4}(NE|NW|SE|SW)?$|((H(P|T|U|Y|Z)|N(A|B|C|D|F|G|H|J|K|L|M|N|O|R|S|T|U|W|X|Y|Z)|OV|S(C|D|E|G|H|J|K|M|N|O|P|R|S|T|U|W|X|Y|Z)|T(A|F|G|L|M|Q|R|V)){1}(\d{4}|\d{6}|\d{8}|\d{10}))$/)
  end

  def is_latlng?
    !!coordinates
  end

  def coordinates
    if matches = self.match(/(-?\d+\.\d+)[,\s]+(-?\d+\.\d+)/)
      matches[1,2]
    else
      nil
    end
  end
  
  def to_latlng(options={})
    if is_gridref?
      Osgb::Gridref.new(self, options).to_latlng
    else
      self.coordinates
    end
  end
  
  def to_wgs84(options={})
    if is_gridref?
      Osgb::Gridref.new(self, options.merge(:datum => :wgs84)).to_latlng
    else
      self.coordinates
    end
  end
  
  def lat(options={})
    to_latlng({:datum => :wgs84}.merge(options))[0]
  end
  
  def lng(options={})
    to_latlng({:datum => :wgs84}.merge(options))[1]
  end  
end
