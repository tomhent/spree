require 'csv'

Spree::Sample.load_sample('option_values')
Spree::Sample.load_sample('products')
Spree::Sample.load_sample('tax_categories')

VARIANTS = CSV.read(File.join(__dir__, 'variants.csv'))

clothing_tax_category = Spree::TaxCategory.find_or_create_by!(name: 'Clothing')
color_option_values = Spree::OptionType.find_by!(name: 'color').option_values
length_option_values = Spree::OptionType.find_by!(name: 'length').option_values
size_option_values = Spree::OptionType.find_by!(name: 'size').option_values

taxons = Spree::Taxon.includes(:children).all
products = Spree::Product.all

VARIANTS.each do |(parent_name, taxon_name, product_name, color_name)|
  parent = taxons.find { |t| t.name == parent_name }
  taxon = taxons.find { |t| t.parent_id == parent.id && t.name == taxon_name }
  product = products.find { |p| p.name == product_name.titleize }
  color = color_option_values.find { |c| c.name == color_name }

  size_option_values.each do |size|
    if parent_name == 'Women' and %w[Dresses Skirts].include?(taxon_name)
      length_option_values.each do |length|
        option_values = [color, length, size]
        product.variants.first_or_create! do |variant|
          variant.cost_price = product.price
          variant.option_values = option_values
          variant.sku = product.sku + '_' + option_values.map(&:name).join('_')
          variant.tax_category = clothing_tax_category
        end
      end
    else
      option_values = [color, size]
      product.variants.first_or_create! do |variant|
        variant.cost_price = product.price
        variant.option_values = option_values
        variant.sku = product.sku + '_' + option_values.map(&:name).join('_')
        variant.tax_category = clothing_tax_category

      end
    end
  end
end
