module Operations::Contractor::Identity
  class Confirm < Operation

    attribute :token

    validates :token, presence: true
    validates :identity, presence: true, error: [::Errors::NotFound]

    def process
      identity.confirm!

      success({ status: :confirmed })
    end

    private

    def identity
      @identity ||= ::ContractorIdentity.find_by(confirmation_token: @token)
    rescue
      nil
    end
  end
end
