module Types
  class Contractor::PaymentCardInputType < BaseInputObject
    argument :card, GraphQL::Types::JSON,  required: true
  end
end
