module Types
  class Identity::EmailInputType < BaseInputObject

    argument :email, String, required: true
    argument :password, String, required: true

  end
end
