module Operations::Types

  class Region < Point

    values do
      attribute :delta_latitude,  Float
      attribute :delta_longitude, Float

      attribute :radius, Float
    end

    def initialize(**args)
      super(**args)

      raise "deltas or radius should be passed" if (@delta_latitude.nil? || @delta_longitude.nil?) && @radius.nil?

      if @radius.nil?
        @radius = Location.distance({
          latitude: @latitude,
          longitude: @longitude
        }, {
          latitude: @latitude + @delta_latitude / 2,
          longitude: @longitude + @delta_longitude / 2
        })
      end

      if @delta_latitude.nil? || @delta_longitude.nil?
        center.delta(@radius).tap do |deltas|
          @delta_latitude = deltas.latitude
          @delta_longitude = deltas.longitude
        end
      end
    end

    def center
      location
    end

    def ==(other)
      return false unless other.is_a?(self.class)
      latitude == other.latitude &&
        longitude == other.longitude &&
        delta_latitude == other.delta_latitude &&
        delta_longitude == other.delta_longitude
    end

    def hash
      latitude.hash + longitude.hash + delta_latitude.hash + delta_longitude.hash
    end

    def eql?(other)
      self == other
    end
  end
end
