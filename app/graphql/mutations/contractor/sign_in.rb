module Mutations
  class Contractor::SignIn < Base

    argument :email, Types::Identity::EmailInputType, required: false
    argument :phone, Types::Identity::PhoneInputType, required: false

    field :token, String, null: true
    field :contractor, Types::ContractorType, null: true

    def authorized?(**args)
      true
    end

    def resolve(email: nil, phone: nil)

      contractor = nil

      if current_user.present? && email.blank? && phone.blank?
        contractor = resolve_by_user(current_user)
      end

      if contractor.blank? && email.present?
        contractor = resolve_by_email email[:email], email[:password]
      end

      if contractor.blank? && phone.present?
        contractor = resolve_by_phone phone[:phone], phone[:password]
      end

      raise ::Errors::NotFound if contractor.blank?

      token = generate_access_token contractor.user

      success(contractor: contractor, token: token )
    rescue Error => e
      error! e
    end

    private

    def resolve_by_email(email, password)
      result = Operations::Contractor::Find.(provider: :email, uid: email, token: password)
      return result[:contractor] if result.success?
      return nil if result.instance_of? Errors::NotFound
      raise result
    end

    def resolve_by_phone(phone, password)
      result = Operations::Contractor::Find.(provider: :phone, uid: phone, token: password)
      return result[:contractor] if result.success?
      return nil if result.instance_of? Errors::NotFound
      raise result
    end

    def resolve_by_user(user)
      result = Operations::Contractor::Find.(user: user)
      return result[:contractor] if result.success?
      return nil if result.instance_of? Errors::NotFound
      raise result
    end

  end
end
