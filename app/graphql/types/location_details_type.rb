module Types
  class LocationDetailsType < BaseObject
    field :place_id, String, null: false
    field :full_address, String, null: false
  end
end
