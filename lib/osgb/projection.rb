module Osgb
  class Projection
    attr_accessor :name, :scale, :phi0, :lambda0, :e0, :n0, :ellipsoid
    @@instances = {}
    
    def initialize(name, attributes)
      @name = name
      @scale = attributes[:scale]
      @phi0 = attributes[:phi0].to_radians
      @lambda0 = attributes[:lambda0].to_radians
      @e0 = attributes[:e0]
      @n0 = attributes[:n0]
      @ellipsoid = Osgb::Ellipsoid[attributes[:ellipsoid]]
      @@instances[name] = self
    end
    
    def self.[](name)
      @@instances[name]
    end
  end
end