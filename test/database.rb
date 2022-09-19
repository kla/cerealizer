module Database
  extend ActiveSupport::Concern

  class_methods do
    def setup_database
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
    end

    def create_tables
      ActiveRecord::Migration.create_table(:orders) do |t|
        t.timestamps
        t.references :user
        t.decimal :paid
      end

      ActiveRecord::Migration.create_table(:users) do |t|
        t.timestamps
        t.string :first_name
        t.string :last_name
      end

      ActiveRecord::Migration.create_table(:items) do |t|
        t.timestamps
        t.references :order
        t.string :name
        t.decimal :price
        t.integer :quantity
      end
    end

    def reset_database
      Order.delete_all
      User.delete_all
      Item.delete_all
    end
  end
end
