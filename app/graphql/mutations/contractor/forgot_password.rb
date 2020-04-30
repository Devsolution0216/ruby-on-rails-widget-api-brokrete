module Mutations
  class Contractor::ForgotPassword < Base

    argument :email, String, required: false
    argument :phone, String, required: false

    field :status, String, null: true

    def authorized?(**args)
      true
    end

    def resolve(**email_or_phone)
      result = Operations::Contractor::Identity::SendReset.(
        provider: provider(**email_or_phone),
        uid: uid(**email_or_phone)
      )

      raise result if result.error?

      success result.success?, status: result[:status]
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
