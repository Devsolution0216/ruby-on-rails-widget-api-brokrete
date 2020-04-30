
module Resolvers
  class Contractor < ContractorBase
    type Types::ContractorType, null: false

    def resolve
      contractor
    end
  end
end
