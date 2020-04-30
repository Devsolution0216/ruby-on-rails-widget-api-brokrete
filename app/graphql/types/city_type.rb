module Types
  class CityType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :country, Types::CountryType, null: false
    field :location, Types::LocationType, null: false
    field :location_details, Types::LocationDetailsType, null: false
  end
end
