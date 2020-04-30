module Types
  class LocationInputType < BaseInputObject
    argument :latitude, Float, required: true
    argument :longitude, Float, required: true
  end
end
