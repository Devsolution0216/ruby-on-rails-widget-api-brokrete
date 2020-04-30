module Operations
  module Contractor
    class ChangePassword < Operation

      attribute :contractor

      attribute :provider
      attribute :uid

      attribute :current_token
      attribute :reset_token

      attribute :token

      validates :token, password: true, presence: true, error: [::Errors::Custom, :incorrect_password]

      def process
        if contractor.present?
          identity = contractor.identities.with_password.first

          result = Identity::Find.(provider: identity.provider, uid: identity.uid, token: current_token)

          halt! result if result.error?
        else
          result = Identity::Find.(provider: provider, uid: uid, reset_token: reset_token)

          halt! result if result.error?

          @contractor = result[:identity].contractor
        end

        with_transaction do

          contractor.identities.with_password.each do |identity|
            Identity::Update.(contractor: contractor, id: identity.id, new_token: token)
          end

          success
        end
      end
    end
  end
end
