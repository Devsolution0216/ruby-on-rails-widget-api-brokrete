module Operations::Contractor::Identity
  class Remove < Operation

    attribute :contractor

    attribute :id
    attribute :identity

    attribute :provider
    attribute :uid

    validates :contractor, presence: true

    validates :identity, presence: true, error: [::Errors::NotFound]

    def process
      identity.destroy

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

  end
end
