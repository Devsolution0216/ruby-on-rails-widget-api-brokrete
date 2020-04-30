module Operations
  module Order
    class Create < Operation

      attribute :product_id
      attribute :product_strength_price_id
      attribute :product_decorate_price_id

      attribute :quantity

      attribute :contractor
      attribute :point, Operations::Types::Point

      attribute :options_id
      attribute :fees_id
      attribute :trucks
      attribute :delivery_time
      attribute :time_between_trucks

      validates :contractor, presence: true
      validates :point, presence: true
      validates :product, presence: true
      validates :product_strength, presence: true
      validates :options_id, presence: true
      validates :fees_id, presence: true
      validates :trucks, presence: true
      validates :delivery_time, presence: true
      validates :time_between_trucks, presence: true

      def process
        result = Order::Validate.(contractor: contractor, product_id: product_id, point: point)
        halt! result if result.error?

        # plant_product = PlantProduct.where(
        #   product: product, product_strength: product_strength, product_decorate: product_decorate
        # )
        #
        # if plant_product.length <= 0
        #   halt! ::Errors::Custom, :invalid, "No plant products"
        # end
        #
        # plants = []
        # plant_product.each { |record|
        #   plants << record.plant
        # }
        # @nearest_plant = Plant.find_nearest_plant(point, plants)
        #
        # order = ::Order.create!(
        #     product: product,
        #     longitude: point.location.longitude,
        #     latitude: point.location.latitude,
        #     product_strength: product_strength,
        #     product_decorate: product_decorate,
        #     city: @nearest_plant.city,
        #     quantity: quantity,
        #     total_price: total_price)
        #
        # order_price = ::OrderPrice.create!(
        #     order: order,
        #     product_strength_price: @product_strength_price,
        #     product_decorate_price: @product_decorate_price,
        #     value: order.total_price
        # )

        # puts "### - " + order.to_json.to_s
        # puts "###"
        # puts "### - " + order_price.to_json.to_s

        success
      end

      protected

      def product
        return nil unless product_id.present?

        @product ||= Product.find product_id
      rescue
        nil
      end

      def product_strength
        unless @product_strength_price
          return nil unless product_strength_price_id.present?

          @product_strength_price = ProductStrengthPrice.find product_strength_price_id
        end
        @product_strength_price&.product_strength
      rescue
        nil
      end

      def product_decorate
        unless @product_decorate_price
          return nil unless product_decorate_price_id.present?

          @product_decorate_price = ProductDecoratePrice.find product_decorate_price_id
        end
        @product_decorate_price&.product_decorate
      rescue
        nil
      end

      def total_price
        decorate_price = @product_decorate_price ? @product_decorate_price.value : 0
        strength_price = @product_strength_price ? @product_strength_price.value : 0

        decorate_price + strength_price
      end

    end
  end
end
