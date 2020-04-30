module Types
  class PlantType < BaseObject
    field :id, ID, null: false

    field :name, String, null: false

    field :supplier, Types::SupplierType, null: false
    field :city, Types::CityType, null: false

    field :delivery_radius, Int, null: false

    field :location, Types::LocationType, null: false
  end
end
