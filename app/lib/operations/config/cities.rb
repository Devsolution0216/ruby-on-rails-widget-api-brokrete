module Operations
  module Config
    class Cities < Operation

      attribute :contractor

      validates :contractor, presence: true

      def process
        success cities: City.all.to_a
      end
    end
  end
end
