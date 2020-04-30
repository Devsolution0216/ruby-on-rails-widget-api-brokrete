module Operations
  module Contractor
    class Find < Operation

      attribute :user

      attribute :provider
      attribute :uid
      attribute :token
      attribute :reset_token

      def process
        if user.present?
          contractor = ::Contractor.find_by(user: user)

          return success(contractor: contractor) if contractor.present?
        end

        result = Identity::Find.(provider: provider, uid: uid, token: token, reset_token: reset_token)

        halt! result if result.error?

        success contractor: result[:identity].contractor
      end
    end
  end
end
