module Types
  class ContractorType < BaseObject
    field :id, ID, null: false
    field :info, Types::Contractor::InfoType, null: false
    field :payments_info, Types::Contractor::PaymentsInfoType, null: false
    field :identities, [Types::Contractor::IdentityType], null: false

    def info
      object
    end

    def payments_info
      object
    end
  end
end
