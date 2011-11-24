module Osgb
  module HasGridref
    def self.included base #:nodoc:
      base.class_eval {
        cattr_accessor :osgb_options
        @@osgb = {}
        extend Osgb::ClassMethods
      }
    end
  end

  module ClassMethods
    def has_gridref name, options = {}
      include Osgb::InstanceMethods
      osgb_options = {
        :lat => 'lat',
        :lng => 'lng',
        :gridref => 'gridref',
        :validation => false,
        :conversion => true
      }.merge(options)
      before_validation :convert_between_gridref_and_latlng if osgb_options[:conversion]
      validates :must_have_location if osgb_options[:validation]
    end
  end
  
  module InstanceMethods
    def must_have_location
      send(cols[:gridref]).is_gridref? || (send("#{cols[:lat]}?") && send("#{cols[:lng]}?"))
    end
    
    def convert_between_gridref_and_latlng
      cols = self.class.osgb_options
      if columns.include?(cols[:lat], cols[:lng], cols[:gridref])
        if send("#{cols[:gridref]}_changed?") || !send("#{cols[:lat]}?") || !send("#{cols[:lng]}?")
          latlng = gridref.coordinates
          send("#{cols[:lat]}=", latlng[0])
          send("#{cols[:lng]}=", latlng[1])
        elsif send("#{cols[:lat]}_changed?") || send("#{cols[:lng]}_changed?") || !send("#{cols[:gridref]}?")
          send("#{cols[:gridref]}=", Osgb::Gridref.from(send(cols[:lat]), send(cols[:lng])))
        end
      end
    end
  end
end