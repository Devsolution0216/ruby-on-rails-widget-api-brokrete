module Types
  class FromToInputType < BaseInputObject
    argument :from, String, required: true
    argument :to, String, required: true
  end
end
