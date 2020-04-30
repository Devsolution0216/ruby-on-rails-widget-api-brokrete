module Mutations
  class Contractor::SignUp < Base

    class IdentityInputData < Types::BaseInputObject
      argument :email, Types::Identity::EmailInputType, required: false
      argument :phone, Types::Identity::PhoneInputType, required: false
    end

    argument :identity, IdentityInputData, required: true

    field :token, String, null: true
    field :contractor, Types::ContractorType, null: true

    def authorized?(**args)
      true
    end

    def resolve(identity: nil)

      email = identity[:email]
      phone = identity[:phone]

      identities = [].tap do |identities|
        identities << {
            provider: :email,
            uid: email[:email],
            token: email[:password]
        } if email.present?

        identities << {
            provider: :phone,
            uid: phone[:phone],
            token: phone[:password]
        } if phone.present?
      end

      result = Operations::Contractor::Create.(
        identities: identities
      )

      raise result if result.error?

      contractor = result[:contractor]

      token = generate_access_token contractor.user

      success(contractor: contractor, token: token )
    rescue Error => e
      error! e
    end

  end
end
