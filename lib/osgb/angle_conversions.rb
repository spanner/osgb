class Numeric
  def to_radians  # presumes self is a number of degrees
    self * Math::PI / 180 
  end

  def to_degrees  # presumes self is a number of radians
    self / (Math::PI / 180)
  end
end
