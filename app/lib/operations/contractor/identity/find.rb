module Operations::Contractor::Identity
  class Find < Operation

    attribute :contractor

    attribute :id
    attribute :provider
    attribute :uid

    attribute :token
    attribute :reset_token

    validate  :validate_uid

    validates :identity, presence: true, error: [::Errors::NotFound]

    validate  :validate_token

    def process
      success identity: identity
    end

    private

    def validate_uid
      if is_email_provider?
        halt! Errors::Custom, :incorrect_email unless EmailValidator.valid? uid
      end

      if is_phone_provider?
        halt! Errors::Custom, :incorrect_phone unless Phonelib.valid? uid
      end
    end

    def identity
      if @identity.blank?
        if contractor.present?
          if id.present?
            @identity = contractor.identities.find(id)
          else
            @identity = contractor.identities.find_by(provider: provider, uid: uid)
          end
        else
          if id.present?
            @identity = ContractorIdentity.find(id: id)
          else
            @identity = ContractorIdentity.find_by(provider: provider, uid: uid)
          end
        end
      end
      @identity
    end

    def validate_token
      return if identity.blank?
      return if contractor.present?

      if reset_token.present?
        return true if identity.reset_token == reset_token
        halt! ::Errors::Custom, :wrong_code
      end

      if token_as_password?
        halt! Errors::Custom, :wrong_password unless identity.token == token
        return
      end

      halt! Errors::Custom unless identity.token == token
    end

    def is_email_provider?
      provider == :email
    end

    def is_phone_provider?
      provider == :phone
    end

    def token_as_password?
      is_email_provider? || is_phone_provider?
    end
  end
end
