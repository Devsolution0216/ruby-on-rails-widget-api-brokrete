module Types
  class Identity::AddInputType < BaseInputObject

    argument :email, String, required: false
    argument :phone, String, required: false

  end
end
