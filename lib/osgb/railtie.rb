require 'osgb'

module Osgb
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      initializer 'osgb.insert_into_active_record' do
        ActiveSupport.on_load :active_record do
          Osgb::Railtie.insert
        end
      end
    end
  end

  class Railtie
    def self.insert
      ActiveRecord::Base.send(:include, Osgb::HasGridref)
    end
  end
end
