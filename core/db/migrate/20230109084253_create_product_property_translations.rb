class CreateProductPropertyTranslations < ActiveRecord::Migration[6.1]
  def change
    if ActiveRecord::Base.connection.table_exists? 'spree_product_property_translations'
      remove_index :spree_product_property_translations, column: :spree_product_property_id, if_exists: true
    else
      create_table :spree_product_property_translations do |t|
        # Translated attribute(s)
        t.string :value
        t.string :filter_param

        t.string  :locale, null: false
        t.references :spree_product_property, null: false, foreign_key: true, index: false

        t.timestamps
      end

      add_index :spree_product_property_translations, :locale, name: :index_spree_product_property_translations_on_locale
    end

    add_index :spree_product_property_translations, [:spree_product_property_id, :locale], name: :unique_product_property_id_per_locale, unique: true
  end
end
