module Types
  class Contractor::InfoType < BaseObject
    field :name, String, null: true
    field :type, String, null: true
    field :company_name, String, null: true
  end
end
