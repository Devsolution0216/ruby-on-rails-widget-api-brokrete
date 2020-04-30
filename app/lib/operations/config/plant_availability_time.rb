module Operations
  module Config
    class PlantAvailabilityTime < Operation

      attribute :contractor
      attribute :plant_id
      attribute :plant

      validates :contractor, presence: true
      validates :plant, presence: true

      def process
        success availability_times: plant.plant_availability_times.to_a
      end

      protected

      def plant
        @plant ||= ::Plant.find plant_id if plant_id.present?
        @plant
      rescue
        nil
      end

    end
  end
end
