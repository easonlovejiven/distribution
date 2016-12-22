# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160913074625) do

  create_table "assets", force: :cascade do |t|
    t.integer  "target_id",   limit: 4
    t.string   "target_type", limit: 255
    t.string   "file",        limit: 255
    t.string   "desc",        limit: 255
    t.string   "key",         limit: 255
    t.integer  "is_default",  limit: 4,   default: 0
    t.string   "sort",        limit: 255
    t.string   "img",         limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "fx_auction_records", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.datetime "dealer_id"
    t.boolean  "active",                 default: true, null: false
    t.integer  "lock_version", limit: 4, default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fx_auctions", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer  "user_limit",    limit: 4
    t.integer  "more_limit",    limit: 4
    t.string   "audtion_level", limit: 255
    t.boolean  "active",                    default: true, null: false
    t.integer  "lock_version",  limit: 4,   default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fx_employees", force: :cascade do |t|
    t.string  "name", limit: 255
    t.integer "role", limit: 4,   default: 0
  end

  create_table "fx_infos", force: :cascade do |t|
    t.integer  "user_id",              limit: 4
    t.decimal  "amount",                         precision: 10, scale: 2, default: 0.0
    t.decimal  "amount1",                        precision: 10, scale: 2, default: 0.0
    t.decimal  "amount2",                        precision: 10, scale: 2, default: 0.0
    t.decimal  "amount3",                        precision: 10, scale: 2, default: 0.0
    t.decimal  "last_month_amount",              precision: 10, scale: 2, default: 0.0
    t.decimal  "current_month_amount",           precision: 10, scale: 2, default: 0.0
    t.integer  "dealer1_count",        limit: 4,                          default: 0
    t.integer  "dealer2_count",        limit: 4,                          default: 0
    t.integer  "dealer3_count",        limit: 4,                          default: 0
    t.boolean  "active",                                                  default: true, null: false
    t.integer  "lock_version",         limit: 4,                          default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dealer_count",         limit: 4,                          default: 0
  end

  create_table "fx_invites", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "used",       limit: 4, default: 0
    t.integer  "used_by",    limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "fx_levels", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "label",           limit: 255
    t.integer  "dealer1_percent", limit: 4,   default: 0
    t.integer  "dealer2_percent", limit: 4,   default: 0
    t.integer  "sort",            limit: 4,   default: 1
    t.boolean  "active",                      default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fx_relations", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "old_user_id",   limit: 4
    t.integer  "dealer_id",     limit: 4
    t.boolean  "active",                  default: true, null: false
    t.integer  "lock_version",  limit: 4, default: 0,    null: false
    t.integer  "lft",           limit: 4
    t.integer  "rgt",           limit: 4
    t.integer  "dealers_count", limit: 4, default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fx_settings", force: :cascade do |t|
    t.string "key",   limit: 255
    t.text   "value", limit: 65535
  end

  create_table "fx_tax_rates", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.decimal  "total_amount",             precision: 10, scale: 2, default: 0.0
    t.decimal  "amount",                   precision: 10, scale: 2, default: 0.0
    t.string   "date",         limit: 255
    t.integer  "state",        limit: 4,                            default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fx_trade_items", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "trade_id",         limit: 4
    t.string   "sku",              limit: 255
    t.integer  "count",            limit: 4,                            default: 1,   null: false
    t.decimal  "jprice",                       precision: 10, scale: 2, default: 0.0
    t.decimal  "price",                        precision: 10, scale: 2, default: 0.0
    t.decimal  "fanli_amount",                 precision: 10, scale: 2, default: 0.0
    t.integer  "fanli_type",       limit: 4,                            default: 0,   null: false
    t.integer  "sort",             limit: 4,                            default: 0,   null: false
    t.decimal  "self_fanli",                   precision: 10, scale: 2, default: 0.0
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.decimal  "total_price",                  precision: 10, scale: 2, default: 0.0
    t.decimal  "total_self_fanli",             precision: 10, scale: 2, default: 0.0
  end

  create_table "fx_trade_rebates", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "user_id",    limit: 4
    t.string   "number",     limit: 255
    t.integer  "sort",       limit: 4,                            default: 0,   null: false
    t.decimal  "amount",                 precision: 10, scale: 2, default: 0.0
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
  end

  create_table "fx_trades", force: :cascade do |t|
    t.string   "number",        limit: 255
    t.string   "name",          limit: 255
    t.integer  "user_id",       limit: 4
    t.integer  "optype",        limit: 4
    t.decimal  "total_amount",              precision: 10, scale: 2, default: 0.0
    t.decimal  "amount",                    precision: 10, scale: 2, default: 0.0
    t.integer  "state",         limit: 4,                            default: 0
    t.boolean  "active",                                             default: true, null: false
    t.integer  "lock_version",  limit: 4,                            default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "rebate",                    precision: 10, scale: 2, default: 0.0
    t.decimal  "refund_amount",             precision: 10, scale: 2, default: 0.0
  end

  create_table "fx_transations", force: :cascade do |t|
    t.integer  "trader_id",       limit: 4
    t.integer  "user_id",         limit: 4
    t.integer  "dealer_level",    limit: 4
    t.string   "subject",         limit: 255
    t.decimal  "amount",                      precision: 10, scale: 2, default: 0.0
    t.decimal  "balance",                     precision: 10, scale: 2, default: 0.0
    t.integer  "sort",            limit: 4
    t.boolean  "active",                                               default: true, null: false
    t.integer  "lock_version",    limit: 4,                            default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "trade_rebate_id", limit: 4
  end

  create_table "fx_upgrades", force: :cascade do |t|
    t.integer "level_id", limit: 4
    t.integer "month",    limit: 4,                          default: 1
    t.integer "count",    limit: 4,                          default: 1
    t.decimal "amount",             precision: 10, scale: 2, default: 0.0
  end

  create_table "fx_users", force: :cascade do |t|
    t.string   "account",            limit: 255
    t.integer  "level_id",           limit: 4
    t.integer  "city_id",            limit: 4
    t.decimal  "total_amount",                   precision: 10, scale: 2, default: 0.0
    t.decimal  "balance",                        precision: 10, scale: 2, default: 0.0
    t.string   "invitation",         limit: 255
    t.integer  "is_remove_relation", limit: 4,                            default: 0
    t.decimal  "cost_amount",                    precision: 10, scale: 2, default: 0.0
    t.boolean  "active",                                                  default: true,  null: false
    t.integer  "state",              limit: 4,                            default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "qrcode_pic",         limit: 255
    t.integer  "rank",               limit: 4,                            default: 10000
    t.integer  "province_rank",      limit: 4,                            default: 10000
    t.integer  "province_id",        limit: 4
    t.decimal  "tax_amount",                     precision: 10, scale: 2, default: 0.0
    t.integer  "upgrade_state",      limit: 4,                            default: 0
  end

  create_table "manage_editors", force: :cascade do |t|
    t.integer  "creator_id",    limit: 4
    t.string   "name",          limit: 255
    t.integer  "role_id",       limit: 4
    t.integer  "company_id",    limit: 4
    t.datetime "destroyed_at"
    t.string   "identifier",    limit: 255
    t.boolean  "active",                    default: true, null: false
    t.integer  "lock_version",  limit: 4,   default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "updater_id",    limit: 4
    t.integer  "department_id", limit: 4
    t.integer  "supervisor_id", limit: 4
    t.string   "position",      limit: 255
    t.string   "prefix",        limit: 255
  end

  create_table "manage_grants", force: :cascade do |t|
    t.integer  "editor_id",    limit: 4
    t.integer  "role_id",      limit: 4
    t.integer  "updater_id",   limit: 4
    t.boolean  "active",                 default: true, null: false
    t.integer  "lock_version", limit: 4, default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",   limit: 4
  end

  add_index "manage_grants", ["active", "editor_id", "role_id"], name: "by_active_and_editor_id_and_role_id", using: :btree

  create_table "manage_logs", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "controller", limit: 4
    t.integer  "action",     limit: 4
    t.integer  "params_id",  limit: 4
    t.datetime "created_at"
  end

  create_table "manage_notifications", force: :cascade do |t|
    t.integer  "app_id",       limit: 4
    t.integer  "user_id",      limit: 4
    t.integer  "receiver_id",  limit: 4
    t.text     "content",      limit: 65535
    t.boolean  "unread",                     default: true
    t.boolean  "active",                     default: true, null: false
    t.integer  "lock_version", limit: 4,     default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manage_roles", force: :cascade do |t|
    t.integer  "creator_id",    limit: 4
    t.string   "name",          limit: 255
    t.text     "description",   limit: 65535
    t.datetime "destroyed_at"
    t.integer  "updater_id",    limit: 4
    t.boolean  "active",                      default: true, null: false
    t.integer  "lock_version",  limit: 4,     default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manage_grant",  limit: 4,     default: 0
    t.integer  "manage_editor", limit: 4,     default: 0
    t.integer  "manage_role",   limit: 4,     default: 0
    t.integer  "manage_user",   limit: 4,     default: 0
    t.integer  "manage_log",    limit: 4,     default: 0
  end

  create_table "manage_users", force: :cascade do |t|
    t.string   "pic",          limit: 255
    t.string   "name",         limit: 255
    t.string   "gender",       limit: 255
    t.date     "birthday"
    t.datetime "login_at"
    t.boolean  "active",                   default: true, null: false
    t.integer  "lock_version", limit: 4,   default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "manage_users", ["birthday"], name: "index_manage_users_on_birthday", using: :btree
  add_index "manage_users", ["created_at"], name: "index_manage_users_on_created_at", using: :btree
  add_index "manage_users", ["id"], name: "index_manage_users_on_id", using: :btree
  add_index "manage_users", ["login_at"], name: "index_manage_users_on_login_at", using: :btree
  add_index "manage_users", ["updated_at"], name: "index_manage_users_on_updated_at", using: :btree

  create_table "train_fees", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "payer_id",   limit: 4
    t.decimal  "amount",               precision: 10, scale: 2, default: 0.0
    t.integer  "state",      limit: 4,                          default: 0
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
  end

end
