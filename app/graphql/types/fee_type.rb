module Types
  class FeeType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :type, String, null: false
    field :details, Types::FeeDetailsType, null: false

    def details
      object.details || {}
    end
  end
end
