module Operations::Contractor::Identity
  class Create < Operation

    attribute :contractor

    attribute :provider
    attribute :uid

    attribute :token

    validates :provider, presence: true
    validates :contractor, presence: true

    validate  :validate_uid
    validate  :validate_token

    def process

      identity = ::ContractorIdentity.by(provider).find_or_initialize_by(uid: uid).tap do |identity|
        identity.token = token
      end

      halt! ::Errors::AlreadyExists.new if identity.contractor_id.present?

      contractor.identities << identity

      success identity: identity
    end

    private

    def token
      if token_as_password? && @token.nil?
        @token = contractor.identities.with_password.first.password
      end

      @token
    rescue
      nil
    end

    def validate_uid
      if is_email_provider?
        halt! Errors::Custom, :incorrect_email unless EmailValidator.valid? uid
      end

      if is_phone_provider?
        halt! Errors::Custom, :incorrect_phone unless Phonelib.valid? uid
      end
    end

    def validate_token
      if token_as_password?
        halt! Errors::Custom, :incorrect_password unless PasswordValidator.valid? token
      end
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
