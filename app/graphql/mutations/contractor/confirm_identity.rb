module Mutations
  class Contractor::ConfirmIdentity < ContractorBase

    argument :email, String, required: false
    argument :phone, String, required: false

    argument :token, String, required: false

    field :status, String, null: false

    def resolve(token: nil, **email_or_phone)

      result =
        if token.present?
          Operations::Contractor::Identity::Confirm.(
            token: token
          )
        else
          Operations::Contractor::Identity::SendConfirmation.(
            contractor: contractor,
            provider: provider(**email_or_phone),
            uid: uid(**email_or_phone)
          )
        end

      raise result if result.error?

      success status: result[:status]
    rescue Error => e
      error! e
    end

    def provider(email: nil, phone: nil)
      return :email if email.present?
      return :phone if phone.present?
      nil
    end

    def uid(email: nil, phone: nil)
      return email if email.present?
      return phone if phone.present?
      nil
    end

  end
end
