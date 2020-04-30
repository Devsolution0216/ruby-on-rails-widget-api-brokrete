module Operations
  module Contractor
    class Create < Operation

      attribute :identities, Array

      validates :identities,  presence: true, error: [Errors::Custom, :invalid, "No identities were provided"]

      validates :email_identity,  presence: true, error: [Errors::Custom, :invalid, "No email identity was provided"]
      validates :phone_identity,  presence: true, error: [Errors::Custom, :invalid, "No phone identity was provided"]

      def process
        contractor = with_transaction do
          contractor = create_contractor
          create_identities contractor
          contractor
        end

        success contractor: contractor
      end

      private

      def email_identity
        identities.select { |value| value[:provider] == :email }
      end

      def phone_identity
        identities.select { |value| value[:provider] == :phone }
      end

      def create_contractor
        ::Contractor.create!(user: User.create!(account_type: :contractor))
      end

      def create_identities(contractor)
        identities.each do |provider:, uid:, token:|
          result = Operations::Contractor::Identity::Create.(
            contractor: contractor,
            provider: provider,
            uid: uid,
            token: token
          )

          halt! result if result.error?
        end
      end
    end
  end
end
