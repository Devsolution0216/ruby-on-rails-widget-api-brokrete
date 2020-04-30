module Operations::Contractor::Identity
  class SendConfirmation < Operation

    attribute :contractor
    attribute :provider
    attribute :uid

    validates :uid, presence: true
    validates :provider, presence: true, inclusion: { in: [:email, :phone] }

    validates :identity, presence: true

    validate :validate_confirmed

    def process
      result = SendSmsConfirmation.  (identity: identity) if is_phone_provider?
      result = SendEmailConfirmation.(identity: identity) if is_email_provider?

      error! :invalid unless result.present?
      halt! result if result.error?

      identity.set_confirmation_token! result[:code]

      success({ status: :was_sent })
    end

    private

    def identity
      @identity ||= Operations::Contractor::Identity::Find.(
        contractor: contractor, provider: provider, uid: uid
      )[:identity]
    rescue
      nil
    end

    def validate_confirmed
      return unless identity.present?

      halt! ::Errors::Custom if identity.confirmed?
    end

    def is_email_provider?
      provider == :email
    end

    def is_phone_provider?
      provider == :phone
    end

    class SendSmsConfirmation < Operation

      CODE_LENGTH = 6

      attribute :identity

      validates :identity, presence: true

      def process
        client.deliver(to: to, code: code)
        success({ code: code })
      rescue Exception => e
        halt! ::Errors::Custom, :invalid, e.message
      end

      private

      def to
        identity.uid
      end

      def code
        @code ||= Array.new(CODE_LENGTH).map { SecureRandom.random_number(10) }.join
      end

      def client
        ::Clients::Sms::ConfirmPhone.new
      end

    end

    class SendEmailConfirmation < Operation

      CODE_LENGTH = 6

      attribute :identity

      validates :identity, presence: true

      def process
        client.deliver(name: name, to: email, code: code)
        success({ code: code })
      rescue Exception => e
        halt! ::Errors::Custom, :invalid, e.message
      end

      private

      def name
        identity.contractor.name
      end

      def email
        identity.uid
      end

      def code
        @code ||= Array.new(CODE_LENGTH).map { SecureRandom.random_number(10) }.join
      end

      def client
        ::Clients::Email::ConfirmEmail.new
      end

    end
  end
end
