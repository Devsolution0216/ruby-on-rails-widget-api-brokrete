module Operations
  module Config
    class ProductPrices < Operation

      attribute :contractor

      attribute :product_id
      attribute :point, Operations::Types::Point

      validates :contractor, presence: true
      validates :point, presence: true
      validates :product, presence: true

      def process
        success product: product,
          prices: {
            decorates: decorates
              .reject { |item| !decorate_prices.has_key?(item.id) }
              .map { |item| {
                product_decorate: item,
                price: select_price(decorate_prices[item.id][:prices])
              }},
            strengths: strengths
              .reject { |item| !strength_prices.has_key?(item.id) }
              .map { |item| {
                product_strength: item,
                price: select_price(strength_prices[item.id][:prices])
              }}
          }
      end

      protected

      def plants
        @plants ||= ::Plant.find_by_location(location: point.location).to_a
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

      def decorates
        @decorates ||= ProductDecorate.find_by_plants(plants).where(product: product).to_a
      end

      def strengths
        @strengths ||= ProductStrength.find_by_plants(plants).where(product: product).to_a
      end

      def decorate_prices
        @decorate_prices ||= reduce(prices(ProductDecoratePrice, decorates).to_a)
      end

      def strength_prices
        @strength_prices ||= reduce(prices(ProductStrengthPrice, strengths).to_a)
      end

      def prices(model, targets)
        model.unscope(:order).distinct.ordered.where(target: targets, plant: plants)
          .or(model.unscope(:order).distinct.ordered.where(target: targets, city: cities))
          .or(model.unscope(:order).distinct.ordered.where(target: targets, supplier: suppliers))
          .or(model.unscope(:order).distinct.ordered.where(target: targets, contractor: contractor))
      end

      def reduce(source)
        result = {}
        source.each do |value|
          key = value.target
          unless result.has_key? key.id
            result[key.id] = {
              target: key,
              prices: []
            }
          end

          result[key.id][:prices] << value
        end

        result
      end

      def select_price(prices)

        get_order = -> (price) {
          return 1 if price.contractor_id == contractor.id
          return 2 if price.plant_id.present?
          return 3 if price.city_id.present?
          return 4 if price.supplier_id.present?
          5
        }

        ordered_prices = prices.sort do |a, b|
          order_a = get_order.call(a)
          order_b = get_order.call(b)

          if order_a == order_b
            a.value <=> b.value
          else
            order_a <=> order_b
          end
        end

        ordered_prices.first
      end

    end
  end
end
