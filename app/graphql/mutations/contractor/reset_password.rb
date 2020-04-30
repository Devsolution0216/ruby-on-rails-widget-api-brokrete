module Mutations
  class Contractor::ResetPassword < Base

    argument :email, String, required: false
    argument :phone, String, required: false

    argument :reset_token, String, required: true

    argument :new_password, String, required: true

    def authorized?(**args)
      true
    end

    def resolve(reset_token:, new_password:, **email_or_phone)
      result = Operations::Contractor::ChangePassword.(
        provider: provider(**email_or_phone),
        uid: uid(**email_or_phone),
        reset_token: reset_token,
        token: new_password)

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
