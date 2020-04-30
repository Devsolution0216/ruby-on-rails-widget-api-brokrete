module Types
  class Identity::PhoneInputType < BaseInputObject

    argument :phone, String, required: true
    argument :password, String, required: true

  end
end
