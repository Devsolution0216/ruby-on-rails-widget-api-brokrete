module Mutations
  class Contractor::ValidateResetToken < ContractorBase

    argument :email, String, required: false
    argument :phone, String, required: false

    argument :reset_token, String, required: true

    field :success, Boolean, null: false

    def authorized?(**args)
      true
    end

    def resolve(reset_token:, **email_or_phone)
      result = Operations::Contractor::Identity::Find.(
        provider: provider(**email_or_phone),
        uid: uid(**email_or_phone),
        reset_token: reset_token
      )

      raise result if result.error?

      success
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
