module Osgb
  class Ellipsoid
    attr_accessor :name, :a, :b
    @@instances = {}

    def initialize(name, a, b)
      @name = name
      @a = a
      @b = b
      @@instances[name] = self
    end
  
    def ecc
      (a**2 - b**2) / (a**2)
    end
    
    def nu_for(phi)
      a / (Math.sqrt(1 - ecc * Math.sin(phi)**2))
    end
    
    def precision
      4 / a
    end
    
    def polar_to_cartesian(phi, lambda)
      h = 0
      nu = nu_for(phi)
      x1 = (nu + h) * Math.cos(phi) * Math.cos(lambda)
      y1 = (nu + h) * Math.cos(phi) * Math.sin(lambda)
      z1 = ((1 - ecc) * nu + h) * Math.sin(phi)
      [x1, y1, z1]
    end
    
    def cartesian_to_polar(x,y,z)
      p = Math.sqrt(x**2 + y**2)
      phi = Math.atan2(z, p*(1-ecc));
      phip = 2 * Math::PI

      count = 0
      while (phi-phip).abs > precision do
        raise RuntimeError "Helmert transformation has not converged. Discrepancy after #{count} cycles is #{phi-phip}" if count >= Osgb::Gridref.iteration_ceiling
        nu = a / Math.sqrt(1 - ecc * Math.sin(phi)**2)
        phip = phi
        phi = Math.atan2(z + ecc * nu * Math.sin(phi), p)
        count += 1
      end 

      lambda = Math.atan2(y, x)
      [phi, lambda]
    end
    
    def self.[](name)
      @@instances[name]
    end
  end
end