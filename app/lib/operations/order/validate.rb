module Operations
  module Order
    class Validate < Operation

      attribute :contractor

      attribute :product_id
      attribute :point, Operations::Types::Point

      validates :contractor, presence: true
      validates :point, presence: true
      validates :product, presence: true

      validate :can_deliver_order

      def process
        success
      end

      protected

      def product
        return nil unless product_id.present?

        @product ||= Product.find product_id
      rescue
        nil
      end

      def plants
        @plants ||= ::Plant.find_by_location(location: point.location).find_by_product(product).to_a
      end

      def can_deliver_order
        has_plant_with_product = false

        if plants.length > 0
          plants.each do |plant|
            if plant.products.where(id: @product.id).any?
              has_plant_with_product = true
              break
            end
          end
        end

        unless has_plant_with_product
          halt! ::Errors::Custom, :invalid, "Can't deliver to this area"
        end
      end

    end
  end
end
