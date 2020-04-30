module Types
  class Contractor::IdentityType < BaseObject
    field :id, ID, null: false
    field :provider, String, null: false
    field :uid, String, null: false
    field :confirmed, Boolean, null: false

    def confirmed
      object.confirmed_at.present?
    end

    def uid
      object.uid
    end
  end
end
