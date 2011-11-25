module Osgb
  class Helmert
    attr_accessor :name, :tx, :ty, :tz, :rx, :ry, :rz, :s
    @@instances = {}

    def initialize(name, attributes)
      @name = name
      @tx = attributes[:tx]
      @ty = attributes[:ty]
      @tz = attributes[:tz]
      @rx = (attributes[:rx]/3600).to_radians
      @ry = (attributes[:ry]/3600).to_radians
      @rz = (attributes[:rz]/3600).to_radians
      @s = attributes[:s]
      @@instances[name] = self
    end
    
    def s1
      s/1e6 + 1
    end
  
    def transform(x,y,z)
      xp = tx + x*s1 - y*rz + z*ry
      yp = ty + x*rz + y*s1 - z*rx
      zp = tz - x*ry + y*rx + z*s1
      [xp, yp, zp]
    end
    
    def self.[](name)
      @@instances[name]
    end
  end
end