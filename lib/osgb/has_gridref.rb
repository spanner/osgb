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
      self.osgb_options = {
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
      options = self.class.osgb_options
      cols = self.class.column_names
      if cols.include?(options[:lat]) && cols.include?(options[:lng]) && cols.include?(options[:gridref])

        if send("#{options[:gridref]}_changed?") || !send("#{options[:lat]}?") || !send("#{options[:lng]}?")
          point = gridref.to_latlng
          send("#{options[:lat]}=", point.lat)
          send("#{options[:lng]}=", point.lng)
          
        elsif send("#{options[:lat]}_changed?") || send("#{options[:lng]}_changed?") || !send("#{options[:gridref]}?")
          send("#{options[:gridref]}=", Osgb::Gridref.from(send(options[:lat]), send(options[:lng])))
        end
        
      else
        raise Osgb::OsgbConfigurationError "OSGB was expecting to see #{options[:lat]}, #{options[:lng]} and #{options[:gridref]} columns."
      end
    end

  end
end