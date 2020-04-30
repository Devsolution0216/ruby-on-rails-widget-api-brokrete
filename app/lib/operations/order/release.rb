module Operations
  module Order
    class Release < Operation
      attribute :contractor
      attribute :order_id

      validates :contractor, presence: true
      validates :order, presence: true

      def process
        @order.status = "in_progress"
        @order.save

        success
      end

      protected

      def order
        return nil unless order_id.present?

        @order ||= ::Order.find order_id
      rescue
        nil
      end

    end
  end
end
