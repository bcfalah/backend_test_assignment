class CarsAddIndexOnPreferredPriceRange < ActiveRecord::Migration[6.1]
  def change
    add_index :users, :preferred_price_range, using: :gist
  end
end
