module Osgb
  # Implementation derived from the Ordnance Survey guide to coordinate systems in the UK
  # http://www.ordnancesurvey.co.uk/oswebsite/gps/information/coordinatesystemsinfo/guidecontents/
  # with help from CPAN module Geography::NationalGrid by and (c) P Kent

  class Gridref
    OsTiles = {
      :a => [0,4], :b => [1,4], :c => [2,4], :d => [3,4], :e => [4,4],
      :f => [0,3], :g => [1,3], :h => [2,3], :j => [3,3], :k => [4,3],
      :l => [0,2], :m => [1,2], :n => [2,2], :o => [3,2], :p => [4,2],
      :q => [0,1], :r => [1,1], :s => [2,1], :t => [3,1], :u => [4,1],
      :v => [0,0], :w => [1,0], :x => [2,0], :y => [3,0], :z => [4,0],
    }
    FalseOrigin = {:e => 2, :n => 1}
    SquareSize = [nil, 10000, 1000, 100, 10, 1]    # shorter grid ref = larger square.

    attr_accessor :gridref, :projection, :ellipsoid, :datum, :options, :precision

    @@iteration_ceiling = 1000
    @@defaults = {
      :projection => :gb,   # mercator projection of input gridref. Can be any projection name: usually :ie or :gb
      :precision => 6       # decimal places in the output lat/long
    }
    
    class << self
      def iteration_ceiling
        @@iteration_ceiling
      end
    end
  
    def initialize(string, options={})
      raise ArgumentError, "invalid grid reference string '#{string}'." unless string.is_gridref?
      options = @@defaults.merge(options)
      @gridref = string.upcase
      @projection = Osgb::Projection[options[:projection]]
      @precision = options[:precision]
      @ellipsoid = @projection.ellipsoid
      @datum = options[:datum]
      self
    end
        
    def tile
      @tile ||= gridref[0,2]
    end
  
    def digits
      @digits ||= gridref[2,10]
    end
  
    def resolution
      digits.length / 2
    end
  
    def offsets
      if tile
        major = OsTiles[tile[0,1].downcase.to_sym ]
        minor = OsTiles[tile[1,1].downcase.to_sym]
        @offset ||= {
          :e => (500000 * (major[0] - FalseOrigin[:e])) + (100000 * minor[0]),
          :n => (500000 * (major[1] - FalseOrigin[:n])) + (100000 * minor[1])
        }
      else
        { :e => 0, :n => 0 }
      end
    end
  
    def easting
      @east ||= offsets[:e] + digits[0, resolution].to_i * SquareSize[resolution]
    end
  
    def northing
      @north ||= offsets[:n] + digits[resolution, resolution].to_i * SquareSize[resolution]
    end
  
    def lat
      round(coordinates[:lat].to_degrees)
    end
  
    def lng
      round(coordinates[:lng].to_degrees)
    end
    
    def round(value)
      if value.method(:round).arity == 0
        multiplier = 10**precision
        (value * multiplier).round.to_f / multiplier
      else
        value.round(precision)
      end
    end
  
    def to_s
      gridref.to_s
    end
  
    def to_latlng
      "#{lat}, #{lng}"
    end

    def coordinates
      unless @coordinates
        # variable names correspond roughly to symbols in the OS algorithm, lowercased:
        # n0 = northing of true origin 
        # e0 = easting of true origin 
        # f0 = scale factor on central meridian
        # phi0 = latitude of true origin 
        # lambda0 = longitude of true origin and central meridian.
        # e2 = eccentricity squared
        # a = length of polar axis of ellipsoid
        # b = length of equatorial axis of ellipsoid
        # ning & eing are the northings and eastings of the supplied gridref
        # phi and lambda are the discovered latitude and longitude
      
        ning = northing
        eing = easting

        n0 = projection.n0
        e0 = projection.e0
        phi0 = projection.phi0
        l0 = projection.lambda0
        f0 = projection.scale
      
        a = ellipsoid.a
        b = ellipsoid.b
        e2 = ellipsoid.ecc
      
        # the rest is juste a transliteration of the OS equations

        n = (a - b) / (a + b)
        m = 0
        phi = phi0
    
        # iterate to within acceptable distance of solution
      
        count = 0
        while ((ning - n0 - m) >= 0.001) do
          raise RuntimeError "Demercatorising equation has not converged. Discrepancy after #{count} cycles is #{ning - n0 - m}" if count >= @@iteration_ceiling

          phi = ((ning - n0 - m) / (a * f0)) + phi
          ma = (1 + n + (1.25 * n**2) + (1.25 * n**3)) * (phi - phi0)
          mb = ((3 * n) + (3 * n**2) + (2.625 * n**3)) * Math.sin(phi - phi0) * Math.cos(phi + phi0)
          mc = ((1.875 * n**2) + (1.875 * n**3)) * Math.sin(2 * (phi - phi0)) * Math.cos(2 * (phi + phi0))
          md = (35/24) * (n**3) * Math.sin(3 * (phi - phi0)) * Math.cos(3 * (phi + phi0))
          m = b * f0 * (ma - mb + mc - md)
          count += 1
        end
      
        # engage alphabet soup
      
        nu = a * f0 * ((1-(e2) * ((Math.sin(phi)**2))) ** -0.5)
        rho = a * f0 * (1-(e2)) * ((1-(e2)*((Math.sin(phi)**2))) ** -1.5)
        eta2 = (nu/rho - 1)
      
        # fire
      
        vii = Math.tan(phi) / (2 * rho * nu)
        viii = (Math.tan(phi) / (24 * rho * (nu ** 3))) * (5 + (3 * (Math.tan(phi) ** 2)) + eta2 - 9 * eta2 * (Math.tan(phi) ** 2) )
        ix = (Math.tan(phi) / (720 * rho * (nu ** 5))) * (61 + (90 * (Math.tan(phi) ** 2)) + (45 * (Math.tan(phi) ** 4)) )
        x = sec(phi) / nu
        xi = (sec(phi) / (6 * nu ** 3)) * ((nu/rho) + 2 * (Math.tan(phi) ** 2))
        xii = (sec(phi) / (120 * nu ** 5)) * (5 + (28 * (Math.tan(phi) ** 2)) + (24 * (Math.tan(phi) ** 4)))
        xiia = (sec(phi) / (5040 * nu ** 7)) * (61 + (662 * (Math.tan(phi) ** 2)) + (1320 * (Math.tan(phi) ** 4)) + (720 * (Math.tan(phi) ** 6)))

        d = eing-e0

        # all of which was just to populate these last two equations:
      
        phi = phi - vii*(d**2) + viii*(d**4) - ix*(d**6)
        lambda = l0 + x*d - xi*(d**3) + xii*(d**5) - xiia*(d**7)

        # phi and lambda are lat and long but note that here we are still in radians and osgb36
        # if a different output datum is required, the helmert transformation remaps the coordinates onto a new globe

        if datum && datum != :osgb36
          target_ellipsoid = Osgb::Ellipsoid[datum]
          
          if helmert = Osgb::Helmert[datum]
            cartesian_coordinates = ellipsoid.polar_to_cartesian(phi, lambda)
            transformed = helmert.transform(*cartesian_coordinates)
            phi, lambda = target_ellipsoid.cartesian_to_polar(*transformed)
          else
            raise RuntimeError, "Missing ellipsoid or helmert transformation for #{datum}"
          end
        end

        @coordinates = {:lat => phi, :lng => lambda}
      end
      @coordinates
    end
    
  private

    def sec(radians)
      1 / Math.cos(radians)
    end
  
  end
end