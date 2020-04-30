module Types
  class Contractor::UpdateInfoInputType < BaseInputObject

    argument :name, String, required: false
    argument :type, String, required: false
    argument :company_name, String, required: false

  end
end
