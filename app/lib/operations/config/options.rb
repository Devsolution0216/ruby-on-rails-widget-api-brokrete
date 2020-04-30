module Operations
  module Config
    class Options < Operation

      attribute :product_id
      attribute :point, Operations::Types::Point

      validates :point, presence: true
      validates :product, presence: true

      def process
        result = []
        option_prices.each do |value|
          result << {
            option: value.option,
            price: value
          }
        end
        success options: result
      end

      protected

      def option_price
        @option_price ||= OptionPrice.all
      end

      def plants
        return @plants if @plants

        plants = ::Plant.find_by_location(location: point.location)
        plants = plants.find_by_product(product) if product.present?

        @plants = plants.to_a
      end

      def product
        return nil unless product_id.present?

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

      def option_prices
        OptionPrice.unscope(:order).distinct.ordered.where(plant: plants)
          .or(OptionPrice.unscope(:order).distinct.ordered.where(city: cities))
          .or(OptionPrice.unscope(:order).distinct.ordered.where(supplier: suppliers))
      end

    end
  end
end
