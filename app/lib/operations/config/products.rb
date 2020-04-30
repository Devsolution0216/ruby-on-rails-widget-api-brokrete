module Operations
  module Config
    class Products < Operation

      attribute :contractor

      attribute :region, Operations::Types::Region

      validates :contractor, presence: true

      def process
        unless has_filter?
          return success products: Product.all.to_a
        end

        success products: Product.find_by_plants(plants).to_a
      end

      protected

      def has_filter?
        region.present?
      end

      def plants
        plants = ::Plant

        plants = plants.find_by_location(location: region.center, radius: region.radius) if region.present?

        plants.all
      end
    end
  end
end
