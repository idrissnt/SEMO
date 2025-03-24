import pandas as pd
import json

def create_excel_template():
    # Create a writer object to save multiple sheets in one Excel file
    writer = pd.ExcelWriter('store_data_template.xlsx', engine='xlsxwriter')
    workbook = writer.book

    # Add formats
    header_format = workbook.add_format({
        'bold': True,
        'bg_color': '#D9EAD3',
        'border': 1
    })
    instruction_format = workbook.add_format({
        'text_wrap': True,
        'bg_color': '#FCE5CD'
    })

    # 1. Stores Sheet
    stores_df = pd.DataFrame(columns=[
        'name*',           # Required, max_length=255
        'address*',        # Required, max_length=255
        'city*',          # Required, max_length=100
        'latitude',        # Optional, decimal(9,6)
        'longitude',       # Optional, decimal(9,6)
        'working_hours*',  # Required, JSON format
        'image_logo',      # Optional, default='stores/default.png'
        'image_banner'     # Optional, default='stores/default.png'
    ])

    # Add example data
    stores_df.loc[0] = [
        'Example Store',
        '123 Main Street',
        'New York',
        40.712800,  # 6 decimal places
        -74.006000, # 6 decimal places
        json.dumps({
            'monday': {'open': '09:00', 'close': '21:00'},
            'tuesday': {'open': '09:00', 'close': '21:00'},
            'wednesday': {'open': '09:00', 'close': '21:00'},
            'thursday': {'open': '09:00', 'close': '21:00'},
            'friday': {'open': '09:00', 'close': '21:00'},
            'saturday': {'open': '10:00', 'close': '18:00'},
            'sunday': {'open': '10:00', 'close': '18:00'}
        }),
        'stores/example_logo.png',    # Example logo path
        'stores/example_banner.jpg'   # Example banner path
    ]

    stores_df.to_excel(writer, sheet_name='Stores', index=False, startrow=2)
    stores_sheet = writer.sheets['Stores']
    
    # Add instructions and validations
    stores_sheet.write(0, 0, 'Instructions:', instruction_format)
    stores_sheet.write(1, 0, '- Fields marked with * are required', instruction_format)
    stores_sheet.write(1, 1, '- Name, Address: max 255 characters', instruction_format)
    stores_sheet.write(1, 2, '- City: max 100 characters', instruction_format)
    stores_sheet.write(1, 3, '- Latitude: between -90 and 90, max 6 decimal places', instruction_format)
    stores_sheet.write(1, 4, '- Longitude: between -180 and 180, max 6 decimal places', instruction_format)
    stores_sheet.write(1, 5, '- Working Hours: JSON format', instruction_format)
    stores_sheet.write(1, 6, '- Image Logo: default image', instruction_format)
    stores_sheet.write(1, 7, '- Image Banner: default image', instruction_format)
    
    # Add data validations
    stores_sheet.data_validation('D4:D1048576', {'type': 'decimal',
                                                'criteria': 'between',
                                                'minimum': -90,
                                                'maximum': 90})
    stores_sheet.data_validation('E4:E1048576', {'type': 'decimal',
                                                'criteria': 'between',
                                                'minimum': -180,
                                                'maximum': 180})

    # 2. Categories Sheet
    categories_df = pd.DataFrame(columns=[
        'store_name*',    # Required, must match a store name
        'name*',          # Required, max_length=255
        'path*',          # Required, for hierarchy
        'description'     # Optional
    ])

    # Add example data for hierarchical categories
    categories_df.loc[0] = [
        'Example Store',
        'Deli',                # Parent category
        'Deli',                # Path is same as name for top-level
        'Fresh deli items'
    ]
    categories_df.loc[1] = [
        'Example Store',
        'Deli Meats',          # Subcategory
        'Deli.Deli_Meats',     # Path shows hierarchy
        'Fresh meat products'
    ]
    categories_df.loc[2] = [
        'Example Store',
        'Chicken',             # Product category
        'Deli.Deli_Meats.Chicken', # Full path to product category
        'Fresh chicken products'
    ]
    categories_df.loc[3] = [
        'Example Store',
        'Cheese',              # Another subcategory under Deli
        'Deli.Cheese',         # Different branch in hierarchy
        'Fresh cheese selection'
    ]

    categories_df.to_excel(writer, sheet_name='Categories', index=False, startrow=2)
    categories_sheet = writer.sheets['Categories']
    
    # Add instructions
    categories_sheet.write(0, 0, 'Instructions:', instruction_format)
    categories_sheet.write(1, 0, '- Fields marked with * are required', instruction_format)
    categories_sheet.write(1, 1, '- Name: max 255 characters', instruction_format)
    categories_sheet.write(1, 2, '- Path: use dots for hierarchy (e.g., Deli.Deli_Meats.Chicken)', instruction_format)
    categories_sheet.write(1, 3, '- Use underscores instead of spaces in paths', instruction_format)
    categories_sheet.write(1, 4, '- Each category must have its full path from root to itself', instruction_format)

    # 3. Products Sheet
    products_df = pd.DataFrame(columns=[
        'name*',          # Required, max_length=255
        'quantity*',      # Required, integer
        'unit*',          # Required, max_length=10
        'price*',         # Required, decimal(10,2)
        'price_per_unit*',# Required, decimal(10,2)
        'description*',   # Required
        'image_url'       # Optional, default='stores/default.png'
    ])

    # Add example data
    products_df.loc[0] = [
        'Chicken Breast',
        100,
        'kg',
        12.99,
        6.99,
        'Fresh chicken breast, price per pound',
        'products/chicken_breast.jpg'  # Example image path
    ]
    
    products_df.loc[1] = [
        'Cheddar Cheese',
        50,
        'piece',
        8.99,
        8.99,
        'Aged cheddar cheese wheel',
        'products/cheddar.jpg'  # Example image path
    ]

    products_df.to_excel(writer, sheet_name='Products', index=False, startrow=2)
    products_sheet = writer.sheets['Products']
    
    # Add instructions and validations
    products_sheet.write(0, 0, 'Instructions:', instruction_format)
    products_sheet.write(1, 0, '- Fields marked with * are required', instruction_format)
    products_sheet.write(1, 1, '- Name: max 255 characters', instruction_format)
    products_sheet.write(1, 2, '- Unit: one of [piece, kg, liter, pack]', instruction_format)
    products_sheet.write(1, 3, '- Price and Price per Unit: max 2 decimal places', instruction_format)
    
    # Add data validations
    products_sheet.data_validation('B4:B1048576', {'type': 'integer',
                                                  'criteria': 'greater than',
                                                  'value': 0})
    products_sheet.data_validation('C4:C1048576', {'type': 'list',
                                                  'source': ['piece', 'kg', 'liter', 'pack']})
    products_sheet.data_validation('D4:E1048576', {'type': 'decimal',
                                                  'criteria': 'greater than',
                                                  'value': 0})

    # 4. Store-Products Sheet
    store_products_df = pd.DataFrame(columns=[
        'store_name*',     # Required, must match a store name
        'product_name*',   # Required, must match a product name
        'category_name*',  # Required, must match a category path
        'price*',         # Required, decimal(10,2)
        'price_per_unit*' # Required, decimal(10,2)
    ])

    # Add example data
    store_products_df.loc[0] = [
        'Example Store',
        'Chicken Breast',
        'Deli.Deli_Meats.Chicken',  # Full path to the category
        12.99,
        6.99  # Price per pound
    ]
    
    # Add another example in a different category
    store_products_df.loc[1] = [
        'Example Store',
        'Cheddar Cheese',
        'Deli.Cheese',  # Different category branch
        8.99,
        8.99  # Price per piece
    ]

    store_products_df.to_excel(writer, sheet_name='Store-Products', index=False, startrow=2)
    store_products_sheet = writer.sheets['Store-Products']
    
    # Add instructions
    store_products_sheet.write(0, 0, 'Instructions:', instruction_format)
    store_products_sheet.write(1, 0, '- Fields marked with * are required', instruction_format)
    store_products_sheet.write(1, 1, '- Store Name must match exactly with a store name from Stores sheet', instruction_format)
    store_products_sheet.write(1, 2, '- Product Name must match exactly with a product name from Products sheet', instruction_format)
    store_products_sheet.write(1, 3, '- Category Name must match exactly with a category path from Categories sheet', instruction_format)
    
    # Add data validations
    store_products_sheet.data_validation('D4:E1048576', {'type': 'decimal',
                                                        'criteria': 'greater than',
                                                        'value': 0})

    # Adjust column widths
    for sheet in [stores_sheet, categories_sheet, products_sheet, store_products_sheet]:
        sheet.set_column('A:Z', 20)  # Set a reasonable width for all columns

    # Save the Excel file
    writer.close()
    
    print("Created store_data_template.xlsx with the following sheets:")
    print("\nStores Sheet:")
    print("- Required fields: name, address, city, working_hours")
    print("- Optional fields: latitude, longitude")
    print("\nCategories Sheet:")
    print("- Required fields: store_name, name, path")
    print("- Optional fields: description")
    print("\nProducts Sheet:")
    print("- All fields are required")
    print("- Units must be one of: piece, kg, liter, pack")
    print("\nStore-Products Sheet:")
    print("- All fields are required")
    print("- Names must match exactly with their respective sheets")
    
if __name__ == '__main__':
    create_excel_template()