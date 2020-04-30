module Operations
  module Plant
    class Find < Operation

      attribute :contractor

      attribute :product_strength_price_id

      attribute :point, Operations::Types::Point

      validates :contractor, presence: true
      validates :point, presence: true
      validates :product_strength_price, presence: true
      validates :plant, presence: true

      def process
        success plant: plant
      end

      protected

      def product_strength_price
        return nil unless product_strength_price_id.present?

        @product_strength_price ||= ProductStrengthPrice.find product_strength_price_id
      rescue
        nil
      end

      def plant
        return nil if product_strength_price.blank?

        return product_strength_price.plant if product_strength_price.plant.present?

        ::Plant.nearest_by(
          location: point.location,
          supplier: product_strength_price.supplier,
          product_strength: product_strength_price.product_strength).to_a.first
      end
    end
  end
end
