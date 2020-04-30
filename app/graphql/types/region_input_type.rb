module Types
  class RegionInputType < LocationInputType
    argument :delta_latitude, Float, required: false
    argument :delta_longitude, Float, required: false
    argument :radius, Float, required: false
  end
end
