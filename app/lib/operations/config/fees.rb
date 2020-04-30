module Operations
  module Config
    class Fees < Operation

      attribute :contractor

      attribute :product_id
      attribute :point, Operations::Types::Point

      validates :contractor, presence: true
      validates :point, presence: true
      validates :product, presence: true

      def process
        result = []
        fee_prices.each do |value|
          result << {
            fee: value.fee,
            price: value
          }
        end
        success fees: result
      end

      protected

      def plants
        return @plants if @plants

        plants = ::Plant.find_by_location(location: point.location)
        plants = plants.find_by_product(product) if product.present?

        @plants = plants.to_a
      end

      def product
        @product ||= Product.find product_id
      rescue
        nil
      end

      def cities
        @cities ||= City.find_by_plants(plants).to_a
      end

      def suppliers
        @suppliers ||= Supplier.find_by_plants(plants).to_a
      end

      def fee_prices
        FeePrice.unscope(:order).distinct.ordered.where(supplier: suppliers)
          .or(FeePrice.unscope(:order).distinct.ordered.where(city: cities))
          .or(FeePrice.unscope(:order).distinct.ordered.where(product: product))
      end

    end
  end
end

