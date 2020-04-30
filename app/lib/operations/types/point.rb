module Operations::Types

  class Point
    include Virtus.value_object

    values do
      attribute :latitude,  Float
      attribute :longitude, Float
    end

    def initialize(**args)
      super(**args)

      raise "latitude should be passed" if @latitude.nil?
      raise "longitude should be passed" if @longitude.nil?
    end

    def location
      Location.new(latitude, longitude)
    end

    def ==(other)
      return false unless other.is_a?(self.class)
      latitude == other.latitude &&
        longitude == other.longitude
    end

    def hash
      latitude.hash + longitude.hash
    end

    def eql?(other)
      self == other
    end
  end
end
