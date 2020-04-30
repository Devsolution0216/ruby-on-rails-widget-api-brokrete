module Operations::Contractor::Identity
  class Update < Operation

    attribute :contractor

    attribute :id
    attribute :identity

    attribute :provider
    attribute :uid

    attribute :new_uid
    attribute :new_token

    validates :contractor, presence: true

    validates :identity, presence: true, error: [::Errors::NotFound]

    validate :validate_params

    def process
      if new_uid.present?
        halt! ::Errors::AlreadyExists.new if identity.class.find_by(uid: new_uid).present?

        identity.uid = new_uid
        identity.reset_confirm
      end

      if new_token.present?
        identity.token = new_token
        identity.clear_reset_token
      end

      identity.save!

      success
    end

    private

    def identity
      @identity ||= Operations::Contractor::Identity::Find.(
        contractor: contractor, id: id, provider: provider, uid: uid
      )[:identity]
    rescue
      nil
    end

    def validate_params
      halt! Errors::Custom, :invalid if new_uid.blank? && new_token.blank?

      if new_uid.present?
        if is_email_provider?
          halt! Errors::Custom, :incorrect_email unless EmailValidator.valid? new_uid
        end

        if is_phone_provider?
          halt! Errors::Custom, :incorrect_phone unless Phonelib.valid? new_uid
        end
      end

      if new_token.present?
        if token_as_password?
          halt! Errors::Custom, :incorrect_password unless PasswordValidator.valid? new_token
        end
      end
    end

    def is_email_provider?
      identity.provider_email?
    rescue
      nil
    end

    def is_phone_provider?
      identity.provider_phone?
    rescue
      nil
    end

    def token_as_password?
      is_email_provider? || is_phone_provider?
    end
  end
end
