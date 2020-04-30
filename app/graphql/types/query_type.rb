module Types
  class QueryType < Types::BaseObject
    field :contractor, resolver: Resolvers::Contractor, null: false
  end
end
