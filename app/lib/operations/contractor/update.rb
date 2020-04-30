module Operations
  module Contractor
    class Update < Operation

      attribute :contractor

      attribute :name
      attribute :type
      attribute :company_name

      validates :contractor, presence: true

      def process
        contractor.name = name unless name.blank?
        contractor.type = type unless type.blank?
        contractor.company_name = company_name unless company_name.blank?

        contractor.save!

        success
      end
    end
  end
end
