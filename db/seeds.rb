# Clear existing records to prevent duplicates on re-seeding
OrderItem.destroy_all
MenuItem.destroy_all
Setting.destroy_all rescue nil
User.destroy_all

# ==========================================
# 1. CREATE ALL STAFF & ADMIN ACCOUNTS (RBAC)
# ==========================================
User.create!([
  {
    name: "Super Administrator",
    email: "admin@newsongcookitz.com",
    password: "password123",
    password_confirmation: "password123",
    role: :super_admin,
    active: true
  },
  {
    name: "Oga Manager",
    email: "manager@newsongcookitz.com",
    password: "password123",
    password_confirmation: "password123",
    role: :manager,
    active: true
  },
  {
    name: "Lead Cashier",
    email: "cashier@newsongcookitz.com",
    password: "password123",
    password_confirmation: "password123",
    role: :cashier,
    active: true
  },
  {
    name: "Chef Head (Kitchen)",
    email: "kitchen@newsongcookitz.com",
    password: "password123",
    password_confirmation: "password123",
    role: :kitchen,
    active: true
  },
  {
    name: "Floor Waiter / Host",
    email: "floor@newsongcookitz.com",
    password: "password123",
    password_confirmation: "password123",
    role: :floor,
    active: true
  },
  {
    name: "Dispatch Rider",
    email: "dispatch@newsongcookitz.com",
    password: "password123",
    password_confirmation: "password123",
    role: :dispatch,
    active: true
  }
])

# ==========================================
# 2. CREATE COMPREHENSIVE MENU & PACKAGES
# ==========================================
MenuItem.create!([
  # --- Special Packages & Combos ---
  { name: "Student Budget Pack", description: "1 Scoop Party Jollof, 1 Fried Beef, 1 Boiled Egg, and 1 Free Pure Water.", price: 1500.0, category: "Special Packages", requires_double_container: false, available: true },
  { name: "The Bachelor's Comfort Pack", description: "1 Scoop Rice & Beans mix, 2 Fried Fish pieces, Fried Plantain, and Free Pure Water.", price: 2200.0, category: "Special Packages", requires_double_container: false, available: true },
  { name: "Oga At The Top Executive Combo", description: "Basmati Jollof, Fried Turkey lap, Moi-Moi, Cole-slaw, and Chilled Maltina.", price: 4500.0, category: "Special Packages", requires_double_container: false, available: true },
  { name: "Queen's Choice Swallow Pack", description: "2 Wraps of Pounded Yam, Egusi Soup with Shaki & Pomo, Beef chunk, and Bottled Water.", price: 3200.0, category: "Special Packages", requires_double_container: true, available: true },
  { name: "Amala Special Deluxe", description: "3 Wraps of Amala, Ewedu & Gbegiri soup mix, 2 Fried Beef chunks, and Pomo.", price: 2800.0, category: "Special Packages", requires_double_container: true, available: true },
  { name: "Ofada Heritage Feast", description: "Full portion of Ofada Rice with Ayamase designer sauce, Titus fish, and Boiled Egg.", price: 3500.0, category: "Special Packages", requires_double_container: false, available: true },
  { name: "Family Sunday Special", description: "Large party tray of Jollof & Fried rice mix, 4 Big Chicken pieces, and Dodo.", price: 8500.0, category: "Special Packages", requires_double_container: false, available: true },
  { name: "Quick Fix Yam & Egg Combo", description: "Fried Yam Slices (6 pcs), 2 Fried Eggs, pepper sauce, and Soda drink.", price: 2000.0, category: "Special Packages", requires_double_container: false, available: true },
  { name: "Healthy Fitness Pack", description: "Unripe Plantain Porridge, Croaker fish piece, and bottled table water.", price: 2800.0, category: "Special Packages", requires_double_container: false, available: true },
  { name: "The Midnight Munchies Pack", description: "Hot Ewa Agoyin beans, fried plantain, 2 pieces of Akara, and chilled Pepsi.", price: 1800.0, category: "Special Packages", requires_double_container: false, available: true },
  # --- Rice & Grains (Per Scoop) ---
  { name: "Party Jollof Rice (Per Scoop)", description: "Smoky firewood-style party jollof rice cooked with rich local spices.", price: 400.0, category: "Rice & Grains", requires_double_container: false, available: true },
  { name: "Fried Rice (Per Scoop)", description: "Richly loaded fried rice with mixed vegetables and seasoning.", price: 450.0, category: "Rice & Grains", requires_double_container: false, available: true },
  { name: "Ofada Rice (Per Scoop)", description: "Unpolished native local rice served hot.", price: 500.0, category: "Rice & Grains", requires_double_container: false, available: true },
  { name: "Coconut Rice (Per Scoop)", description: "Sweet aroma coconut rice cooked in fresh coconut milk stock.", price: 450.0, category: "Rice & Grains", requires_double_container: false, available: true },
  { name: "Native Jollof Rice (Per Scoop)", description: "Traditional palm oil jollof rice loaded with locust beans and crayfish.", price: 400.0, category: "Rice & Grains", requires_double_container: false, available: true },
  { name: "Special Mixed Rice & Beans (Per Scoop)", description: "Combined portion of rice and honey beans.", price: 450.0, category: "Rice & Grains", requires_double_container: false, available: true },
  { name: "Turmeric Spiced Rice (Per Scoop)", description: "Fragrant yellow rice seasoned with aromatic herbs.", price: 450.0, category: "Rice & Grains", requires_double_container: false, available: true },
  { name: "Basmati Party Jollof (Per Scoop)", description: "Premium long-grain basmati rice cooked party style.", price: 600.0, category: "Rice & Grains", requires_double_container: false, available: true },
  { name: "Basmati Fried Rice (Per Scoop)", description: "Premium basmati fried rice with mixed veggies and liver.", price: 650.0, category: "Rice & Grains", requires_double_container: false, available: true },
  { name: "Plain White Rice (Per Scoop)", description: "Steam-cooked long grain white rice.", price: 300.0, category: "Rice & Grains", requires_double_container: false, available: true },
  # --- Beans (Per Scoop / Portion) ---
  { name: "Honey Beans / Oloyin (Per Scoop)", description: "Savory cooked brown beans with fish extract and palm oil.", price: 400.0, category: "Beans", requires_double_container: false, available: true },
  { name: "Ewa Agoyin (Plain Beans, Per Scoop)", description: "Well-mashed soft honey beans ready for sweet Agoyin sauce.", price: 450.0, category: "Beans", requires_double_container: false, available: true },
  { name: "Brown Beans Porridge (Per Scoop)", description: "Rich beans porridge cooked with onions and crayfish.", price: 400.0, category: "Beans", requires_double_container: false, available: true },
  { name: "Stewed Beans & Corn (Adalu, Per Scoop)", description: "Traditional sweet corn and beans medley.", price: 500.0, category: "Beans", requires_double_container: false, available: true },
  { name: "Beans and Plantain Pottage (Per Scoop)", description: "Hearty combination of beans and ripe plantain chunks.", price: 550.0, category: "Beans", requires_double_container: false, available: true },
  { name: "Mashed Beans Special (Per Scoop)", description: "Smooth seasoned bean puree.", price: 450.0, category: "Beans", requires_double_container: false, available: true },
  # --- Solids / Swallow (Per Wrap) ---
  { name: "Amala (Per Wrap)", description: "Smooth, dark-brown yam flour swallow.", price: 300.0, category: "Solids", requires_double_container: true, available: true },
  { name: "Pounded Yam (Per Wrap)", description: "Classic pounded yam made from fresh tubers.", price: 500.0, category: "Solids", requires_double_container: true, available: true },
  { name: "Yellow Garri / Eba (Per Wrap)", description: "Golden yellow garri swallow prepared with boiling water.", price: 300.0, category: "Solids", requires_double_container: true, available: true },
  { name: "White Garri / Eba (Per Wrap)", description: "White garri swallow.", price: 300.0, category: "Solids", requires_double_container: true, available: true },
  { name: "Semovita / Semo (Per Wrap)", description: "Smooth wheat-based swallow option.", price: 400.0, category: "Solids", requires_double_container: true, available: true },
  { name: "Wheat Meal (Per Wrap)", description: "Nutritious brown wheat swallow.", price: 400.0, category: "Solids", requires_double_container: true, available: true },
  { name: "Fufu / Akpu (Per Wrap)", description: "Traditional fermented cassava swallow.", price: 300.0, category: "Solids", requires_double_container: true, available: true },
  { name: "Oat Meal Swallow (Per Wrap)", description: "Healthy fiber-rich oat swallow.", price: 500.0, category: "Solids", requires_double_container: true, available: true },
  { name: "Cassava Starch / Usi (Per Wrap)", description: "Traditional yellowish oil-cured starch swallow.", price: 600.0, category: "Solids", requires_double_container: true, available: true },
  { name: "Plantain Flour Swallow (Elubo Ogede, Per Wrap)", description: "Special dietary green plantain swallow.", price: 450.0, category: "Solids", requires_double_container: true, available: true },
  # --- Stew & Soup (Per Scoop) ---
  { name: "Egusi Soup (Per Scoop)", description: "Rich melon seed soup cooked with stockfish and palm oil.", price: 600.0, category: "Stew & Soup", requires_double_container: true, available: true },
  { name: "Ewedu Soup (Per Scoop)", description: "Freshly blended green slimy ewedu leaves.", price: 300.0, category: "Stew & Soup", requires_double_container: true, available: true },
  { name: "Gbegiri Soup (Per Scoop)", description: "Smooth mashed brown beans soup.", price: 300.0, category: "Stew & Soup", requires_double_container: true, available: true },
  { name: "Ewedu & Gbegiri Combined (Per Scoop)", description: "The classic Lagos-style combo soup base.", price: 500.0, category: "Stew & Soup", requires_double_container: true, available: true },
  { name: "Ayamase / Designer Stew (Per Scoop)", description: "Hot bleached palm oil green pepper sauce with locust beans.", price: 700.0, category: "Stew & Soup", requires_double_container: true, available: true },
  { name: "Buka Red Tomato Stew (Per Scoop)", description: "Classic local peppery tomato stew base.", price: 500.0, category: "Stew & Soup", requires_double_container: true, available: true },
  { name: "Efo Riro Vegetable Soup (Per Scoop)", description: "Deeply nutritious spinach soup loaded with locust beans and crayfish.", price: 650.0, category: "Stew & Soup", requires_double_container: true, available: true },
  { name: "Ogbono Soup (Per Scoop)", description: "Draw seed soup cooked with savory stock.", price: 600.0, category: "Stew & Soup", requires_double_container: true, available: true },
  { name: "Oha Soup (Per Scoop)", description: "Traditional Eastern aromatic oha leaf soup.", price: 700.0, category: "Stew & Soup", requires_double_container: true, available: true },
  { name: "Fisherman Seafood Soup (Per Scoop)", description: "Rich coastal fish and seafood infused soup.", price: 1000.0, category: "Stew & Soup", requires_double_container: true, available: true },
  # --- Yam & Porridge ---
  { name: "Native Yam Porridge / Asaro (Per Scoop)", description: "Soft tuber yam cooked down in rich pepper mix and palm oil.", price: 600.0, category: "Yam & Porridge", requires_double_container: false, available: true },
  { name: "Fried Yam Slices (3 Pieces)", description: "Crispy golden fried yam chunks.", price: 400.0, category: "Yam & Porridge", requires_double_container: false, available: true },
  { name: "Boiled Tuber Yam (Per Slice)", description: "Soft boiled white yam slice.", price: 300.0, category: "Yam & Porridge", requires_double_container: false, available: true },
  { name: "Sweet Potato Porridge (Per Scoop)", description: "Savory orange sweet potato pottage.", price: 500.0, category: "Yam & Porridge", requires_double_container: false, available: true },
  { name: "Boiled Sweet Potato (Per Slice)", description: "Tender boiled sweet potato.", price: 300.0, category: "Yam & Porridge", requires_double_container: false, available: true },
  { name: "Unripe Plantain Porridge (Per Scoop)", description: "Healthy iron-rich unripe plantain pottage.", price: 600.0, category: "Yam & Porridge", requires_double_container: false, available: true },
  { name: "Ripe Plantain Porridge (Per Scoop)", description: "Sweet ripe plantain pottage.", price: 550.0, category: "Yam & Porridge", requires_double_container: false, available: true },
  { name: "Yam and Plantain Mixed Porridge (Per Scoop)", description: "Combined yam and plantain pottage.", price: 650.0, category: "Yam & Porridge", requires_double_container: false, available: true },
  { name: "Roasted Yam Slice (Per Piece)", description: "Coal-roasted local yam slice.", price: 300.0, category: "Yam & Porridge", requires_double_container: false, available: true },
  { name: "Cocoyam Porridge / Esuru (Per Scoop)", description: "Traditional savory cocoyam pottage.", price: 500.0, category: "Yam & Porridge", requires_double_container: false, available: true },
  # --- Extras & Proteins ---
  { name: "Fried Beef (Per Piece)", description: "Tender seasoned beef chunk, well fried.", price: 500.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  { name: "Fried Chicken (Per Piece - Lap/Breast)", description: "Big golden-fried chicken piece.", price: 1500.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  { name: "Fried Turkey (Per Piece)", description: "Juicy seasoned turkey piece.", price: 2000.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  { name: "Titus Fish (Fried, Per Piece)", description: "Whole juicy fried Titus fish portion.", price: 1000.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  { name: "Croaker Fish (Fried, Per Piece)", description: "Premium croaker fish piece.", price: 1800.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  { name: "Stockfish / Panla (Per Piece)", description: "Flavorful seasoned stockfish piece.", price: 800.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  { name: "Cow Skin / Pomo (Big Size, Per Piece)", description: "Soft cooked cow skin.", price: 300.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  { name: "Cow Tripe / Shaki (Per Scoop)", description: "Tender diced cow tripe.", price: 600.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  { name: "Cow Foot (Per Piece)", description: "Soft gelatinous cow foot piece.", price: 1000.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  { name: "Fried Plantain / Dodo (5 Slices)", description: "Sweet ripe plantain slices fried golden.", price: 400.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  { name: "Boiled Egg (Per Piece)", description: "Hard-boiled fresh egg.", price: 300.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  { name: "Moi-Moi (Per Wrap)", description: "Steamed blended bean pudding.", price: 500.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  { name: "Akara (Bean Cake, 3 Pieces)", description: "Freshly fried hot bean fritters.", price: 300.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  { name: "Asun (Spiced Diced Goat Meat, Per Scoop)", description: "Peppered smoky chopped goat meat.", price: 1200.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  { name: "Peppered Snail (Per Piece)", description: "Juicy giant snail in spicy pepper sauce.", price: 1500.0, category: "Extras & Proteins", requires_double_container: false, available: true },
  # --- Drinks & Free Water ---
  { name: "Pure Water Sachet", description: "Clean, chilled sachet water. Absolutely free for all customers!", price: 0.0, category: "Drinks", requires_double_container: false, available: true },
  { name: "Bottled Table Water (75cl)", description: "Chilled bottled table water.", price: 300.0, category: "Drinks", requires_double_container: false, available: true },
  { name: "Chilled Pepsi (50cl Pet Bottle)", description: "Cold 50cl bottle soda.", price: 400.0, category: "Drinks", requires_double_container: false, available: true },
  { name: "Chilled Coca-Cola (50cl Pet Bottle)", description: "Cold 50cl bottle soda.", price: 400.0, category: "Drinks", requires_double_container: false, available: true },
  { name: "Chilled Sprite (50cl Pet Bottle)", description: "Cold 50cl bottle soda.", price: 400.0, category: "Drinks", requires_double_container: false, available: true },
  { name: "Fanta (50cl Pet Bottle)", description: "Cold 50cl bottle soda.", price: 400.0, category: "Drinks", requires_double_container: false, available: true },
  { name: "Maltina Can (330ml)", description: "Chilled nourishing malt beverage.", price: 600.0, category: "Drinks", requires_double_container: false, available: true },
  { name: "Amstel Malta Can (330ml)", description: "Chilled premium malt drink.", price: 600.0, category: "Drinks", requires_double_container: false, available: true },
  { name: "Fayrouz Pear Drink (Can)", description: "Sparkling non-alcoholic pear drink.", price: 600.0, category: "Drinks", requires_double_container: false, available: true },
  { name: "Bigi Cola (50cl Pet Bottle)", description: "Chilled Bigi cola soda.", price: 300.0, category: "Drinks", requires_double_container: false, available: true },
  { name: "Bigi Apple / Tropical (50cl)", description: "Chilled fruit flavored soda.", price: 300.0, category: "Drinks", requires_double_container: false, available: true },
  { name: "Fearless Energy Drink (Can)", description: "Revitalizing energy drink.", price: 700.0, category: "Drinks", requires_double_container: false, available: true },
  { name: "Hollandia Yoghurt (500ml)", description: "Rich creamy fruit yoghurt.", price: 1200.0, category: "Drinks", requires_double_container: false, available: true },
  { name: "Chivita 100% Juice Pack", description: "Fresh fruit juice pack.", price: 1000.0, category: "Drinks", requires_double_container: false, available: true },
  { name: "Chapman Cocktail (Plastic Cup)", description: "Refreshing local signature cocktail drink.", price: 800.0, category: "Drinks", requires_double_container: false, available: true }
])

# ==========================================
# 3. CREATE INITIAL SYSTEM CONFIGURATIONS
# ==========================================
Setting.find_or_create_by!(key: 'maintenance_mode') do |s|
  s.value = 'false'
  s.description = 'Toggles application-wide maintenance mode.'
end

Setting.find_or_create_by!(key: 'default_currency') do |s|
  s.value = 'NGN'
  s.description = 'Global currency symbol used across stations.'
end

Setting.find_or_create_by!(key: 'platform_name') do |s|
  s.value = 'Newsong Cookitz Enterprise'
  s.description = 'Master system application title.'
end

puts "Successfully seeded #{User.count} staff accounts, #{MenuItem.count} menu items, and system configurations!"