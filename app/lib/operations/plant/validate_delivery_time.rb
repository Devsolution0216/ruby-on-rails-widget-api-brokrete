module Operations
  module Plant
    class ValidateDeliveryTime < Operation

      attribute :contractor
      attribute :plant_id
      attribute :plant
      attribute :delivery_time

      validates :contractor, presence: true
      validates :plant, presence: true
      validates :delivery_time, presence: true
      validates :availability_times, presence: true

      def process
        halt! ::Errors::Custom, :invalid, "Can't deliver at this time" if !opened? || closed?

        success
      end

      protected

      def plant
        @plant ||= ::Plant.find plant_id if plant_id.present?
        @plant
      rescue
        nil
      end

      def availability_times
        @availability_times ||= plant.plant_availability_times.to_a
      rescue
        nil
      end

      def opened?
        availability_times.select { |time| time.status_opened? && validate_rrule(time.value) }.present?
      end

      def closed?
        availability_times.select { |time| time.status_closed? && validate_rrule(time.value) }.present?
      end

      def delivery_time
        Time.parse(super)
      rescue
        nil
      end

      def validate_rrule(rrule)
        dtstart = Time.now.utc.change({hour: 0, min: 0, sec: 0})
        rrule = RRule::Rule.new(rrule, dtstart: dtstart)

        before = delivery_time - 1.minute
        after = delivery_time + 1.minute

        rrule.between(before, after).present?
      rescue
        false
      end

    end
  end
end
