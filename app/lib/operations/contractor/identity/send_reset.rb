module Operations::Contractor::Identity
  class SendReset < Operation

    CODE_LENGTH = 6

    attribute :provider
    attribute :uid

    validates :uid, presence: true
    validates :provider, presence: true, inclusion: { in: [:email, :phone] }

    validates :identity, presence: true, error: [::Errors::NotFound]
    validates :client, presence: true

    validate :validate_confirmed

    def process
      client.deliver(name: name, to: to, code: code)

      identity.set_reset_token! code

      success({ status: :was_sent })
    rescue Exception => e
      halt! ::Errors::Custom, :invalid, e.inspect
    end

    private

    def validate_confirmed
      return unless identity.present?

      halt! ::Errors::Custom, :not_confirmed unless identity.confirmed?
    end

    def identity
      @identity ||= ContractorIdentity.by(provider).find_by(uid: uid)
    rescue
      nil
    end

    def name
      identity.contractor.name
    end

    def to
      identity.uid
    end

    def is_email_provider?
      provider == :email
    end

    def is_phone_provider?
      provider == :phone
    end

    def code
      @code ||= Array.new(CODE_LENGTH).map { SecureRandom.random_number(10) }.join
    end

    def client
      return ::Clients::Sms::ResetPasswordPhone.new if is_phone_provider?
      return ::Clients::Email::ResetPasswordEmail.new if is_email_provider?
      nil
    end
  end
end
