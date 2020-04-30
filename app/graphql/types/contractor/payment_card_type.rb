module Types
  class Contractor::PaymentCardType < BaseObject
    field :id, Int,                           null: false
    field :details, GraphQL::Types::JSON,     null: false
  end
end
