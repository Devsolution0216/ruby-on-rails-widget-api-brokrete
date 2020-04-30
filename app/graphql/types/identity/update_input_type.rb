module Types
  class Identity::UpdateInputType < BaseInputObject

    argument :change, [ChangeInputType], required: false
    argument :add, [AddInputType], required: false
    argument :remove, [RemoveInputType], required: false

  end
end
