module Operations
  module Config
    class Plants < Operation

      attribute :contractor

      attribute :product_id
      attribute :region, Operations::Types::Region

      validates :contractor, presence: true
      validates :region, presence: true

      def process
        success plants: plants.to_a
      end

      protected

      def product
        return nil unless product_id.present?

        @product ||= Product.find product_id
      rescue
        nil
      end

      def plants
        plants = ::Plant.unscope(:order).distinct.ordered

        plants = plants.find_by_location(location: region.center, radius: region.radius) if region.present?
        plants = plants.find_by_product(product) if product.present?

        plants.all
      end
    end
  end
end
