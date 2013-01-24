Gem::Specification.new do |s|
  s.name        = "osgb"
  s.version     = "0.3.0"
  s.author      = "William Ross"
  s.email       = "will@spanner.org"
  s.homepage    = "http://github.com/spanner/osgb"
  s.summary     = "Grid reference translation to and from lat/long."
  s.description = "Converts between Ordnance Survey grid references and lat/long points, including transformation between datums so that you can turn grid references into GPS points."

  s.files        = Dir["{lib,spec}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_development_dependency 'rspec', '~> 2.6.0'
  s.required_rubygems_version = ">= 1.3.4"
end
