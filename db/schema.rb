# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_11_013945) do
  create_table "app_settings", force: :cascade do |t|
    t.boolean "allow_staff_override"
    t.string "app_name"
    t.datetime "created_at", null: false
    t.boolean "maintenance_mode"
    t.string "operational_mode"
    t.string "paystack_link"
    t.string "receipt_footer_note"
    t.datetime "updated_at", null: false
    t.string "whatsapp_number"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "containers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.decimal "packaging_price"
    t.string "packaging_type"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_containers_on_order_id"
  end

  create_table "menu_items", force: :cascade do |t|
    t.boolean "available"
    t.string "category"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "in_stock", default: true, null: false
    t.string "name"
    t.decimal "price"
    t.boolean "requires_double_container"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_menu_items_on_category_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "container_id"
    t.datetime "created_at", null: false
    t.boolean "is_appended"
    t.string "item_name"
    t.decimal "item_price"
    t.string "name"
    t.integer "order_id", null: false
    t.decimal "price"
    t.integer "quantity"
    t.datetime "updated_at", null: false
    t.index ["container_id"], name: "index_order_items_on_container_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "added_by"
    t.datetime "created_at", null: false
    t.string "customer_name"
    t.string "dispatch_status"
    t.string "email"
    t.string "floor_status"
    t.string "fulfillment_type"
    t.decimal "grand_total"
    t.string "kitchen_status"
    t.text "notes"
    t.string "payment_method"
    t.string "phone"
    t.string "service_mode"
    t.string "source"
    t.string "status"
    t.decimal "total_amount"
    t.datetime "updated_at", null: false
  end

  create_table "payment_transactions", force: :cascade do |t|
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.string "gateway"
    t.text "metadata"
    t.integer "order_id", null: false
    t.string "reference"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payment_transactions_on_order_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.string "payment_method"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.string "name"
    t.decimal "price"
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key"
    t.datetime "updated_at", null: false
    t.string "value"
  end

  create_table "system_settings", force: :cascade do |t|
    t.string "app_name"
    t.datetime "created_at", null: false
    t.boolean "maintenance_mode"
    t.string "paystack_link"
    t.datetime "updated_at", null: false
    t.string "whatsapp_number"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "encrypted_password"
    t.integer "failed_login_attempts"
    t.datetime "lock_until"
    t.string "name"
    t.string "otp_code"
    t.datetime "otp_sent_at"
    t.string "password_digest"
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role"
    t.string "station"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "containers", "orders"
  add_foreign_key "menu_items", "categories"
  add_foreign_key "order_items", "containers"
  add_foreign_key "order_items", "orders"
  add_foreign_key "payment_transactions", "orders"
  add_foreign_key "payments", "orders"
end
