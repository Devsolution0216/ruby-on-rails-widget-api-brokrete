module Types
  class Identity::RemoveInputType < BaseInputObject

    argument :email, String, required: false
    argument :phone, String, required: false

  end
end
