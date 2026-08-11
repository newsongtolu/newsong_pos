# config/initializers/menu_data.rb

MENU_CATEGORIES = {
  "Special Packages" => [
    { name: "Newsong Combo 1", price: 4500, description: "Ofada Rice, Ayamase sauce, fried plantain, and Titus fish." },
    { name: "Chairman's Plate", price: 6000, description: "Pounded Yam, rich Egusi soup, tender bush meat, and cold malt." },
    { name: "Student Special", price: 3000, description: "Party Jollof Rice, fried chicken, fresh salad, and Coca-Cola." },
    { name: "OAU Legend Pack", price: 3500, description: "Amala, Gbegiri, Ewedu, assorted meat, and lemonade." },
    { name: "Cookitz Executive", price: 5200, description: "Fried Rice, grilled turkey, Moi Moi, and canned malt." },
    { name: "Family Feast Box", price: 15000, description: "Large party Jollof, 4 fried chickens, coleslaw, and 1.5L drink." },
    { name: "Quick Fix Combo", price: 2200, description: "Eba, Egusi soup, beef, and bottled water." },
    { name: "Weekend Flex Pack", price: 4800, description: "Coconut rice, grilled fish, dodo, and Chapman." },
    { name: "Budget Saver", price: 1800, description: "Rice and beans mix, small fish, and bottled water." },
    { name: "Swallow Special", price: 2800, description: "Semovita, Efo Riro, cow skin (ponmo), and water." }
  ],

  "Rice & Grains" => [
    { name: "Party Jollof Rice (Per Scoop)", price: 500, description: "Smoky Nigerian party jollof served per standard scoop." },
    { name: "Fried Rice Special (Per Scoop)", price: 600, description: "Loaded with mixed veggies and spices per scoop." },
    { name: "Ofada Rice (Per Scoop)", price: 500, description: "Local unpolished Ofada rice per scoop." },
    { name: "Coconut Rice (Per Scoop)", price: 600, description: "Rich coconut-infused rice per scoop." },
    { name: "Local Buka Rice (Per Scoop)", price: 400, description: "Classic white rice per scoop." },
    { name: "Rice and Beans Mix (Per Scoop)", price: 500, description: "Balanced half-and-half rice and beans per scoop." },
    { name: "Curry Rice (Per Scoop)", price: 500, description: "Savory yellow curry rice per scoop." },
    { name: "Native Palm Oil Rice (Per Scoop)", price: 600, description: "Local local-style palm oil rice per scoop." },
    { name: "Jollof Rice (Extra Scoop)", price: 500, description: "Additional single scoop of jollof." },
    { name: "Fried Rice (Extra Scoop)", price: 600, description: "Additional single scoop of fried rice." }
  ],

  "Solids (Swallow)" => [
    { name: "Pounded Yam (Per Wrap)", price: 500, description: "Freshly pounded yam per wrap." },
    { name: "Amala (Per Wrap)", price: 400, description: "Smooth dark yam flour swallow per wrap." },
    { name: "Eba - Garri (Per Wrap)", price: 300, description: "Standard garri swallow per wrap." },
    { name: "Semovita (Per Wrap)", price: 400, description: "Smooth wheat-based semo wrap." },
    { name: "Wheat Meal (Per Wrap)", price: 400, description: "Healthy whole wheat swallow wrap." },
    { name: "Oat Swallow (Per Wrap)", price: 500, description: "Nutritious oat meal swallow per wrap." },
    { name: "Pounded Yam (Big Wrap)", price: 700, description: "Extra heavy wrap of pounded yam." },
    { name: "Amala (Extra Wrap)", price: 400, description: "Standard extra wrap of hot amala." },
    { name: "Semovita (Big Wrap)", price: 500, description: "Extra filling wrap of semo." },
    { name: "Eba (Big Wrap)", price: 400, description: "Large filling portion of garri swallow." }
  ],

  "Stew & Soup" => [
    { name: "Egusi Soup (Per Portion)", price: 800, description: "Rich melon soup portion." },
    { name: "Efo Riro (Per Portion)", price: 900, description: "Rich vegetable soup cooked with palm oil." },
    { name: "Okra Soup (Per Portion)", price: 800, description: "Fisherman style drawn okra soup." },
    { name: "Gbegiri Soup (Per Portion)", price: 300, description: "Smooth blended brown beans soup." },
    { name: "Ewedu Soup (Per Portion)", price: 300, description: "Fresh green jute leaves soup." },
    { name: "Edikang Ikong (Per Portion)", price: 1200, description: "Traditional Cross River vegetable soup." },
    { name: "Oha Soup (Per Portion)", price: 1000, description: "Traditional Eastern soup with tender oha leaves." },
    { name: "Banga Soup (Per Portion)", price: 1100, description: "Sweet palm fruit extract soup." },
    { name: "Tomato Red Stew (Per Ladle)", price: 500, description: "Classic blended tomato and pepper base stew." },
    { name: "Ayamase / Ofada Sauce (Per Ladle)", price: 900, description: "Bleached palm oil green pepper sauce." }
  ],

  "Yam" => [
    { name: "Boiled Yam (Per Slice)", price: 400, description: "Soft boiled white yam slice." },
    { name: "Fried Yam (Per Portion)", price: 500, description: "Golden crispy fried yam slices." },
    { name: "Yam Porridge / Asaro (Per Scoop)", price: 600, description: "Standard pot-cooked yam pottage per scoop." },
    { name: "Asaro Deluxe (Per Plate)", price: 1200, description: "Loaded yam pottage portion." },
    { name: "Boiled Yam with Egg Sauce", price: 1500, description: "Yam slices served with rich tomato egg sauce." },
    { name: "Fried Yam with Pepper Sauce", price: 1200, description: "Fried yam served with shawa pepper." },
    { name: "Roasted Yam Slice", price: 500, description: "Coals roasted yam per slice." },
    { name: "Yam Porridge with Fish", price: 1000, description: "Asaro topped with a piece of fish." },
    { name: "Peppered Yam Cubes (Portion)", price: 800, description: "Bite-sized fried yam tossed in spicy sauce." },
    { name: "Yam and Plantain Mix", price: 1000, description: "Mixed plate of fried yam and sweet dodo." }
  ],

  "Beans" => [
    { name: "Ewa Agoyin (Per Scoop)", price: 500, description: "Soft mashed beans per standard scoop." },
    { name: "Plain Cooked Beans (Per Scoop)", price: 400, description: "Simple tender boiled beans per scoop." },
    { name: "Beans Porridge / Ewa Riro (Per Scoop)", price: 500, description: "Beans cooked in rich tomato and pepper sauce." },
    { name: "Ewa Agoyin with Sauce", price: 800, description: "Mashed beans with spicy dark Agoyin sauce." },
    { name: "Beans and Plantain Combo", price: 1000, description: "Beans served with sweet fried plantains." },
    { name: "Beans and Bread (Agege)", price: 800, description: "Classic street combo of beans and soft bread." },
    { name: "Beans Porridge with Fish", price: 1400, description: "Ewa Riro served with a piece of fish." },
    { name: "Plain Beans with Dodo", price: 900, description: "Plain beans served alongside fried plantain." },
    { name: "Extra Agoyin Pepper Sauce", price: 300, description: "Extra portion of dark Agoyin oil sauce." },
    { name: "Special Pot Beans Portion", price: 1200, description: "Rich beans porridge loaded with seasoning." }
  ],

  "Extras & Proteins" => [
    { name: "Fried Chicken (Per Piece)", price: 1500, description: "Single juicy piece of fried chicken." },
    { name: "Fried Turkey (Per Piece)", price: 2000, description: "Single seasoned and deep-fried turkey cut." },
    { name: "Titus Fish (Per Piece)", price: 1200, description: "Single full piece of cooked/fried mackerel fish." },
    { name: "Beef (Per Piece)", price: 400, description: "Single tender piece of cow meat." },
    { name: "Assorted Meat (Per Piece)", price: 500, description: "Single piece of shaki, liver, or intestine." },
    { name: "Cow Skin / Ponmo (Per Piece)", price: 300, description: "Single juicy piece of cooked ponmo." },
    { name: "Fried Plantain / Dodo (Per Portion)", price: 500, description: "Portion of golden sweet fried plantain slices." },
    { name: "Moi Moi (Per Wrap)", price: 500, description: "Standard wrap of steamed bean pudding." },
    { name: "Boiled Egg (Per Piece)", price: 300, description: "Single hard-boiled egg." },
    { name: "Coleslaw / Salad (Per Portion)", price: 500, description: "Freshly shredded cabbage, carrot, and cream dressing." }
  ],

  "Drinks" => [
    { name: "Bottled Water (75cl)", price: 300, description: "Chilled table water." },
    { name: "Coca-Cola (50cl)", price: 500, description: "Cold pet bottle Coca-Cola." },
    { name: "Pepsi (50cl)", price: 500, description: "Cold pet bottle Pepsi." },
    { name: "Fanta (50cl)", price: 500, description: "Refreshing orange soda." },
    { name: "Sprite (50cl)", price: 500, description: "Crisp lemon-lime soda." },
    { name: "Maltina (Can)", price: 700, description: "Rich malt drink in a can." },
    { name: "Amstel Malta (Can)", price: 700, description: "Less sweet premium malt drink." },
    { name: "Bigi Cola (50cl)", price: 400, description: "Affordable pet bottle cola." },
    { name: "Bigi Apple (50cl)", price: 400, description: "Sweet apple-flavored soft drink." },
    { name: "Bigi Tropical (50cl)", price: 400, description: "Fruity tropical soft drink." },
    { name: "Fearless Energy Drink", price: 800, description: "Energy booster drink." },
    { name: "Climax Energy Drink", price: 800, description: "Popular energy drink can." },
    { name: "Chapman", price: 1000, description: "Freshly made fruity cocktail drink." },
    { name: "Zobo Drink (Bottle)", price: 400, description: "Cold, natural spiced hibiscus drink." },
    { name: "Chivita Active (Pack)", price: 1200, description: "Fruit juice pack." },
    { name: "5Alive Pulpy Orange", price: 800, description: "Orange juice with fruit pulp." },
    { name: "Hollandia Yoghurt (Small)", price: 600, description: "Creamy flavored yoghurt drink." }
  ]
}