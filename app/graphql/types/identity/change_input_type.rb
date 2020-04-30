module Types
  class Identity::ChangeInputType < BaseInputObject

    argument :email, ::Types::FromToInputType, required: false
    argument :phone, ::Types::FromToInputType, required: false
    argument :password, ::Types::FromToInputType, required: false

  end
end
