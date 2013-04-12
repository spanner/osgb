module Osgb
  class OsgbError < StandardError; end
  class OsgbConfigurationError < Osgb::OsgbError; end
  class OsgbConversionError < Osgb::OsgbError; end
end
