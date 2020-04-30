module Types
  class LocationType < BaseObject
    field :latitude, Float, null: false
    field :longitude, Float, null: false
  end
end
