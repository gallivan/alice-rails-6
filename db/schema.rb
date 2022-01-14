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

ActiveRecord::Schema.define(version: 2019_07_26_230250) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_aliases", id: :serial, force: :cascade do |t|
    t.integer "system_id", null: false
    t.integer "account_id", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_aliases_on_account_id"
    t.index ["system_id", "account_id"], name: "account_alias_uq", unique: true
    t.index ["system_id"], name: "index_account_aliases_on_system_id"
  end

  create_table "account_portfolios", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "portfolio_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "portfolio_id"], name: "index_account_portfolios_on_account_id_and_portfolio_id", unique: true
    t.index ["account_id"], name: "index_account_portfolios_on_account_id"
    t.index ["portfolio_id"], name: "index_account_portfolios_on_portfolio_id"
  end

  create_table "account_types", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "account_type_code_uq", unique: true
    t.index ["name"], name: "account_type_name_uq", unique: true
  end

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.integer "entity_id", null: false
    t.integer "account_type_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group_id"
    t.index ["code"], name: "account_code_uq", unique: true
    t.index ["id", "group_id"], name: "index_accounts_on_id_and_group_id", unique: true
    t.index ["name"], name: "account_name_uq", unique: true
  end

  create_table "active_admin_comments", id: :serial, force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.integer "author_id"
    t.string "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "adjustment_types", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "adjustment_type_code_uq", unique: true
    t.index ["name"], name: "adjustment_type_name_uq", unique: true
  end

  create_table "adjustments", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "adjustment_type_id"
    t.integer "journal_entry_id"
    t.decimal "amount"
    t.integer "currency_id"
    t.date "posted_on"
    t.string "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "segregation_id", null: false
    t.date "as_of_on"
  end

  create_table "booker_reports", id: :serial, force: :cascade do |t|
    t.date "posted_on"
    t.string "kind", null: false
    t.string "fate", null: false
    t.text "data", null: false
    t.text "goof_error"
    t.text "goof_trace"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "root"
    t.index ["fate"], name: "index_booker_reports_on_fate"
    t.index ["kind"], name: "index_booker_reports_on_kind"
    t.index ["posted_on"], name: "index_booker_reports_on_posted_on"
  end

  create_table "chargeable_types", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "chargeable_types_code_uq", unique: true
    t.index ["name"], name: "chargeable_types_name_uq", unique: true
  end

  create_table "chargeables", id: :serial, force: :cascade do |t|
    t.integer "chargeable_type_id", null: false
    t.integer "claim_set_id", null: false
    t.integer "currency_id", null: false
    t.decimal "amount", null: false
    t.date "begun_on", null: false
    t.date "ended_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chargeable_type_id", "claim_set_id"], name: "chargeables_uq", unique: true
  end

  create_table "charges", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "chargeable_id", null: false
    t.integer "currency_id", null: false
    t.integer "segregation_id", null: false
    t.decimal "amount", null: false
    t.string "memo", null: false
    t.date "posted_on", null: false
    t.date "as_of_on", null: false
    t.integer "journal_entry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "claim_aliases", id: :serial, force: :cascade do |t|
    t.integer "system_id", null: false
    t.integer "claim_id", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["system_id", "claim_id"], name: "index_claim_aliases_on_system_id_and_claim_id", unique: true
  end

  create_table "claim_marks", id: :serial, force: :cascade do |t|
    t.integer "system_id"
    t.integer "claim_id"
    t.date "posted_on"
    t.decimal "mark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "approved", null: false
    t.string "mark_traded"
    t.decimal "open", precision: 16, scale: 8
    t.decimal "high", precision: 16, scale: 8
    t.decimal "low", precision: 16, scale: 8
    t.decimal "last", precision: 16, scale: 8
    t.decimal "change", precision: 16, scale: 8
    t.integer "volume"
    t.integer "interest"
    t.index ["system_id", "claim_id", "posted_on"], name: "claim_marks_uq", unique: true
  end

  create_table "claim_set_aliases", id: :serial, force: :cascade do |t|
    t.integer "system_id", null: false
    t.integer "claim_set_id", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["system_id", "claim_set_id"], name: "index_claim_set_aliases_on_system_id_and_claim_set_id", unique: true
  end

  create_table "claim_sets", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sector"
    t.index ["code"], name: "claim_set_uq", unique: true
  end

  create_table "claim_sub_types", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "claim_sub_type_code_uq", unique: true
    t.index ["name"], name: "claim_sub_type_name_uq", unique: true
  end

  create_table "claim_types", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "claim_type_code_uq", unique: true
    t.index ["name"], name: "claim_type_name_uq", unique: true
  end

  create_table "claims", id: :serial, force: :cascade do |t|
    t.integer "claim_set_id", null: false
    t.integer "claim_type_id", null: false
    t.integer "entity_id"
    t.integer "claimable_id", null: false
    t.string "claimable_type", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.decimal "size", default: "1.0", null: false
    t.decimal "point_value", default: "1.0", null: false
    t.integer "point_currency_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claimable_id", "claimable_type"], name: "claim_uq", unique: true
    t.index ["entity_id", "code"], name: "claim_entity_code_uq", unique: true
  end

  create_table "clearing_venue_types", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "clearing_venue_type_code_uq", unique: true
    t.index ["name"], name: "clearing_venue_type_name_uq", unique: true
  end

  create_table "clearing_venues", id: :serial, force: :cascade do |t|
    t.integer "entity_id", null: false
    t.integer "clearing_venue_type_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "clearing_venue_code_uq", unique: true
    t.index ["name"], name: "clearing_venue_name_uq", unique: true
  end

  create_table "currencies", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "currency_code_uq", unique: true
    t.index ["name"], name: "currency_name_uq", unique: true
  end

  create_table "currency_marks", id: :serial, force: :cascade do |t|
    t.integer "currency_id"
    t.date "posted_on"
    t.decimal "mark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id", "posted_on"], name: "currency_marks_uq", unique: true
    t.index ["currency_id"], name: "index_currency_marks_on_currency_id"
    t.index ["posted_on"], name: "index_currency_marks_on_posted_on"
  end

  create_table "deal_leg_fills", id: :serial, force: :cascade do |t|
    t.integer "deal_leg_id"
    t.integer "system_id", null: false
    t.integer "dealing_venue_id", null: false
    t.string "dealing_venue_done_id", null: false
    t.integer "account_id"
    t.integer "claim_id"
    t.decimal "done", null: false
    t.decimal "price", null: false
    t.string "price_traded", null: false
    t.date "posted_on", null: false
    t.date "traded_on", null: false
    t.datetime "traded_at", null: false
    t.integer "position_id"
    t.integer "booker_report_id"
    t.string "kind", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dealing_venue_id", "dealing_venue_done_id", "claim_id", "account_id"], name: "deal_leg_fills_uq", unique: true
  end

  create_table "deal_legs", id: :serial, force: :cascade do |t|
    t.integer "deal_id", null: false
    t.integer "claim_id", null: false
    t.integer "sort"
    t.decimal "todo", null: false
    t.decimal "done"
    t.decimal "todo_price"
    t.decimal "done_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deal_types", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "deal_type_code_uq", unique: true
    t.index ["name"], name: "deal_type_name_uq", unique: true
  end

  create_table "dealing_venue_aliases", id: :serial, force: :cascade do |t|
    t.integer "dealing_venue_id", null: false
    t.integer "system_id", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dealing_venue_id", "system_id", "code"], name: "dealing_venue_aliases_uq"
  end

  create_table "dealing_venue_types", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "dealing_venue_type_code_uq", unique: true
    t.index ["name"], name: "dealing_venue_type_name_uq", unique: true
  end

  create_table "dealing_venues", id: :serial, force: :cascade do |t|
    t.integer "entity_id", null: false
    t.integer "dealing_venue_type_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "dealing_venue_code_uq", unique: true
    t.index ["name"], name: "dealing_venue_name_uq", unique: true
  end

  create_table "deals", id: :serial, force: :cascade do |t|
    t.integer "deal_type_id", null: false
    t.integer "account_id", null: false
    t.date "posted_on", null: false
    t.date "traded_on", null: false
    t.decimal "todo", null: false
    t.decimal "done"
    t.decimal "todo_price", null: false
    t.decimal "done_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "duties", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_duties_on_code", unique: true
    t.index ["name"], name: "index_duties_on_name", unique: true
  end

  create_table "entities", force: :cascade do |t|
    t.integer "entity_type_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "entity_code_uq", unique: true
    t.index ["name"], name: "entity_name_uq", unique: true
  end

  create_table "entity_aliases", id: :serial, force: :cascade do |t|
    t.integer "system_id"
    t.integer "entity_id"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["system_id", "entity_id"], name: "index_entity_aliases_on_system_id_and_entity_id", unique: true
  end

  create_table "entity_roles", id: :serial, force: :cascade do |t|
    t.integer "entity_id", null: false
    t.integer "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id", "role_id"], name: "entity_role_uq", unique: true
  end

  create_table "entity_types", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "entity_type_code_uq", unique: true
    t.index ["name"], name: "entity_type_name_uq", unique: true
  end

  create_table "fill_charge_journal_entries", id: :serial, force: :cascade do |t|
    t.integer "deal_leg_fill_id"
    t.integer "charge_id"
    t.integer "journal_entry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "format_types", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "format_type_code_uq", unique: true
    t.index ["name"], name: "format_type_name_uq", unique: true
  end

  create_table "futures", id: :serial, force: :cascade do |t|
    t.integer "claimable_id"
    t.date "expires_on", null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "first_holding_on"
    t.date "first_intent_on"
    t.date "first_delivery_on"
    t.date "last_trade_on"
    t.date "last_intent_on"
    t.date "last_delivery_on"
  end

  create_table "journal_entries", id: :serial, force: :cascade do |t|
    t.integer "journal_id", null: false
    t.integer "journal_entry_type_id", null: false
    t.integer "account_id", null: false
    t.integer "currency_id", null: false
    t.date "posted_on", null: false
    t.date "as_of_on", null: false
    t.decimal "amount", null: false
    t.string "memo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "segregation_id", null: false
  end

  create_table "journal_entry_types", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "journal_entry_type_code_uq", unique: true
    t.index ["name"], name: "journal_entry_type_name_uq", unique: true
  end

  create_table "journal_types", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "journal_type_code_uq", unique: true
    t.index ["name"], name: "journal_type_name_uq", unique: true
  end

  create_table "journals", id: :serial, force: :cascade do |t|
    t.integer "journal_type_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "journal_code_uq", unique: true
    t.index ["name"], name: "journal_name_uq", unique: true
  end

  create_table "ledger_entries", id: :serial, force: :cascade do |t|
    t.integer "ledger_id", null: false
    t.integer "ledger_entry_type_id", null: false
    t.integer "account_id", null: false
    t.integer "currency_id", null: false
    t.date "posted_on", null: false
    t.date "as_of_on", null: false
    t.decimal "amount", null: false
    t.string "memo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "segregation_id", null: false
    t.index ["posted_on", "account_id", "ledger_id", "ledger_entry_type_id", "currency_id", "segregation_id"], name: "ledger_entries_uq", unique: true
  end

  create_table "ledger_entry_types", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "ledger_entry_type_code_uq", unique: true
    t.index ["name"], name: "ledger_entry_type_name_uq", unique: true
  end

  create_table "ledger_types", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "ledger_type_code_uq", unique: true
    t.index ["name"], name: "ledger_type_name_uq", unique: true
  end

  create_table "ledgers", id: :serial, force: :cascade do |t|
    t.integer "ledger_type_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "ledger_code_uq", unique: true
    t.index ["name"], name: "ledger_name_uq", unique: true
  end

  create_table "managed_accounts", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "account_id"], name: "index_managed_accounts_on_user_id_and_account_id", unique: true
  end

  create_table "margin_calculators", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "margin_request_statuses", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "margin_requests", id: :serial, force: :cascade do |t|
    t.integer "margin_id"
    t.integer "margin_request_status_id"
    t.string "body"
    t.string "fail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "posted_on"
    t.index ["margin_id"], name: "index_margin_requests_on_margin_id"
    t.index ["margin_request_status_id"], name: "index_margin_requests_on_margin_request_status_id"
  end

  create_table "margin_response_statuses", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "margin_responses", id: :serial, force: :cascade do |t|
    t.integer "margin_request_id"
    t.integer "margin_response_status_id"
    t.string "body"
    t.string "fail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "posted_on"
    t.index ["margin_request_id"], name: "index_margin_responses_on_margin_request_id"
    t.index ["margin_response_status_id"], name: "index_margin_responses_on_margin_response_status_id"
  end

  create_table "margin_statuses", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "margins", id: :serial, force: :cascade do |t|
    t.integer "portfolio_id", null: false
    t.integer "margin_calculator_id", null: false
    t.integer "margin_status_id", null: false
    t.integer "currency_id", null: false
    t.string "remote_portfolio_id"
    t.string "remote_margin_id"
    t.decimal "initial", precision: 12, scale: 2
    t.decimal "maintenance", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "posted_on"
    t.index ["currency_id"], name: "index_margins_on_currency_id"
    t.index ["margin_calculator_id"], name: "index_margins_on_margin_calculator_id"
    t.index ["margin_status_id"], name: "index_margins_on_margin_status_id"
    t.index ["portfolio_id"], name: "index_margins_on_portfolio_id"
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.string "source", null: false
    t.string "format", null: false
    t.string "head"
    t.text "body", null: false
    t.string "tail"
    t.string "handler"
    t.boolean "handled", default: false, null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["handled"], name: "index_messages_on_handled"
    t.index ["source"], name: "index_messages_on_source"
  end

  create_table "money_lines", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "currency_id", null: false
    t.date "posted_on", null: false
    t.decimal "beginning_balance", default: "0.0", null: false
    t.decimal "cash", default: "0.0", null: false
    t.decimal "pnl_futures", default: "0.0", null: false
    t.decimal "pnl_options", default: "0.0", null: false
    t.decimal "adjustments", default: "0.0", null: false
    t.decimal "rebates", default: "0.0", null: false
    t.decimal "charges", default: "0.0", null: false
    t.decimal "ledger_balance", default: "0.0", null: false
    t.decimal "open_trade_equity", default: "0.0", null: false
    t.decimal "cash_account_balance", default: "0.0", null: false
    t.decimal "margin", default: "0.0", null: false
    t.decimal "long_option_value", default: "0.0", null: false
    t.decimal "short_option_value", default: "0.0", null: false
    t.decimal "net_option_value", default: "0.0", null: false
    t.decimal "net_liquidating_balance", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "kind"
    t.decimal "currency_mark"
    t.integer "segregation_id", null: false
    t.index ["account_id", "currency_id", "segregation_id", "posted_on", "kind"], name: "money_lines_uq", unique: true
  end

  create_table "monies", id: :serial, force: :cascade do |t|
    t.integer "claimable_id"
    t.integer "currency_id", null: false
    t.date "settled_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "packer_reports", id: :serial, force: :cascade do |t|
    t.date "posted_on", null: false
    t.string "kind", null: false
    t.string "fate", null: false
    t.text "data", null: false
    t.text "goof_error"
    t.text "goof_trace"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "root"
    t.index ["fate"], name: "index_packer_reports_on_fate"
    t.index ["kind"], name: "index_packer_reports_on_kind"
    t.index ["posted_on"], name: "index_packer_reports_on_posted_on"
  end

  create_table "picker_reports", id: :serial, force: :cascade do |t|
    t.date "posted_on"
    t.string "kind"
    t.string "fate"
    t.text "data"
    t.text "goof_error"
    t.text "goof_trace"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "root"
    t.index ["fate"], name: "index_picker_reports_on_fate"
    t.index ["kind"], name: "index_picker_reports_on_kind"
    t.index ["posted_on"], name: "index_picker_reports_on_posted_on"
  end

  create_table "portfolio_positions", id: :serial, force: :cascade do |t|
    t.integer "portfolio_id", null: false
    t.integer "position_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_id"], name: "index_portfolio_positions_on_portfolio_id"
    t.index ["position_id"], name: "index_portfolio_positions_on_position_id"
  end

  create_table "portfolios", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "note"
    t.date "posted_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "position_netting_types", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "position_netting_type_code_uq", unique: true
    t.index ["name"], name: "position_netting_type_name_uq", unique: true
  end

  create_table "position_nettings", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "currency_id", null: false
    t.integer "claim_id", null: false
    t.integer "position_netting_type_id", null: false
    t.integer "bot_position_id", null: false
    t.integer "sld_position_id", null: false
    t.date "posted_on", null: false
    t.decimal "done", null: false
    t.decimal "bot_price", null: false
    t.decimal "sld_price", null: false
    t.string "bot_price_traded", null: false
    t.string "sld_price_traded", null: false
    t.decimal "pnl", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "position_statuses", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "position_status_code_uq", unique: true
    t.index ["name"], name: "position_status_name_uq", unique: true
  end

  create_table "position_transfers", id: :serial, force: :cascade do |t|
    t.integer "fm_position_id", null: false
    t.integer "to_position_id", null: false
    t.decimal "bot_transfered", null: false
    t.decimal "sld_transfered", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "positions", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "claim_id", null: false
    t.date "posted_on", null: false
    t.date "traded_on", null: false
    t.decimal "price", null: false
    t.string "price_traded", null: false
    t.decimal "bot", default: "0.0", null: false
    t.decimal "sld", default: "0.0", null: false
    t.decimal "bot_off", default: "0.0", null: false
    t.decimal "sld_off", default: "0.0", null: false
    t.decimal "net", default: "0.0", null: false
    t.decimal "mark"
    t.decimal "ote"
    t.integer "currency_id", null: false
    t.integer "position_status_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "claim_id", "posted_on", "traded_on", "price"], name: "positions_uq"
  end

  create_table "quickfix_event_log_lines", force: :cascade do |t|
    t.datetime "time"
    t.string "beginstring"
    t.string "sendercompid"
    t.string "sendersubid"
    t.string "senderlocid"
    t.string "targetcompid"
    t.string "targetsubid"
    t.string "targetlocid"
    t.string "session_qualifier"
    t.text "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quickfix_incoming_log_lines", force: :cascade do |t|
    t.datetime "time"
    t.string "beginstring"
    t.string "sendercompid"
    t.string "sendersubid"
    t.string "senderlocid"
    t.string "targetcompid"
    t.string "targetsubid"
    t.string "targetlocid"
    t.string "session_qualifier"
    t.text "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quickfix_messages", force: :cascade do |t|
    t.string "beginstring"
    t.string "sendercompid"
    t.string "sendersubid"
    t.string "senderlocid"
    t.string "targetcompid"
    t.string "targetsubid"
    t.string "targetlocid"
    t.string "session_qualifier"
    t.integer "msgseqnum"
    t.text "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["beginstring", "sendercompid", "sendersubid", "senderlocid", "targetcompid", "targetsubid", "targetlocid", "session_qualifier", "msgseqnum"], name: "quickfix_messages_uq", unique: true
  end

  create_table "quickfix_outgoing_log_lines", force: :cascade do |t|
    t.datetime "time"
    t.string "beginstring"
    t.string "sendercompid"
    t.string "sendersubid"
    t.string "senderlocid"
    t.string "targetcompid"
    t.string "targetsubid"
    t.string "targetlocid"
    t.string "session_qualifier"
    t.text "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quickfix_sessions", force: :cascade do |t|
    t.string "beginstring"
    t.string "sendercompid"
    t.string "sendersubid"
    t.string "senderlocid"
    t.string "targetcompid"
    t.string "targetsubid"
    t.string "targetlocid"
    t.string "session_qualifier"
    t.datetime "creation_time"
    t.integer "incoming_seqnum"
    t.integer "outgoing_seqnum"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["beginstring", "sendercompid", "sendersubid", "senderlocid", "targetcompid", "targetsubid", "targetlocid", "session_qualifier"], name: "quickfix_sessions_uq", unique: true
  end

  create_table "report_type_parameters", id: :serial, force: :cascade do |t|
    t.string "handle", null: false
    t.string "bucket", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "report_type_report_type_parameters", id: :serial, force: :cascade do |t|
    t.integer "report_type_id", null: false
    t.integer "report_type_parameter_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "report_types", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "report_type_code_uq", unique: true
    t.index ["name"], name: "report_type_name_uq", unique: true
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.integer "report_type_id"
    t.integer "format_type_id"
    t.string "memo"
    t.string "location"
    t.date "posted_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["format_type_id"], name: "index_reports_on_format_type_id"
    t.index ["location"], name: "reports_uq", unique: true
    t.index ["report_type_id"], name: "index_reports_on_report_type_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "role_code_uq", unique: true
    t.index ["name"], name: "role_name_uq", unique: true
  end

  create_table "runtime_knobs", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "runtime_switches", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.boolean "is_on", null: false
    t.string "note", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "segregations", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spread_legs", force: :cascade do |t|
    t.bigint "spread_id"
    t.bigint "claim_id"
    t.integer "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_id"], name: "index_spread_legs_on_claim_id"
    t.index ["spread_id"], name: "index_spread_legs_on_spread_id"
  end

  create_table "spreads", force: :cascade do |t|
    t.integer "claimable_id"
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statement_adjustments", id: :serial, force: :cascade do |t|
    t.date "posted_on"
    t.date "stated_on"
    t.integer "account_id"
    t.string "account_code"
    t.string "adjustment_code"
    t.string "journal_code"
    t.string "currency_code"
    t.decimal "amount"
    t.string "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_statement_adjustments_on_account_id"
    t.index ["posted_on"], name: "index_statement_adjustments_on_posted_on"
    t.index ["stated_on"], name: "index_statement_adjustments_on_stated_on"
  end

  create_table "statement_charges", id: :serial, force: :cascade do |t|
    t.date "posted_on"
    t.date "stated_on"
    t.integer "account_id"
    t.string "account_code"
    t.string "charge_code"
    t.string "journal_code"
    t.string "currency_code"
    t.decimal "amount"
    t.string "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statement_commissions", id: :serial, force: :cascade do |t|
    t.date "posted_on"
    t.date "stated_on"
    t.integer "account_id"
    t.string "account_code"
    t.string "commission_code"
    t.string "journal_code"
    t.string "currency_code"
    t.decimal "amount"
    t.string "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_statement_commissions_on_account_id"
    t.index ["posted_on"], name: "index_statement_commissions_on_posted_on"
    t.index ["stated_on"], name: "index_statement_commissions_on_stated_on"
  end

  create_table "statement_deal_leg_fills", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.string "account_code"
    t.string "claim_code"
    t.string "claim_name"
    t.date "stated_on"
    t.date "posted_on"
    t.date "traded_on"
    t.decimal "bot"
    t.decimal "sld"
    t.decimal "net"
    t.decimal "price"
    t.string "price_traded"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_code", "claim_code", "posted_on", "traded_on", "price", "price_traded"], name: "statement_deal_leg_fill_uq", unique: true
    t.index ["posted_on"], name: "index_statement_deal_leg_fills_on_posted_on"
    t.index ["stated_on"], name: "index_statement_deal_leg_fills_on_stated_on"
  end

  create_table "statement_fees", id: :serial, force: :cascade do |t|
    t.date "posted_on"
    t.date "stated_on"
    t.integer "account_id"
    t.string "account_code"
    t.string "fee_code"
    t.string "journal_code"
    t.string "currency_code"
    t.decimal "amount"
    t.string "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_statement_fees_on_account_id"
    t.index ["posted_on"], name: "index_statement_fees_on_posted_on"
    t.index ["stated_on"], name: "index_statement_fees_on_stated_on"
  end

  create_table "statement_money_lines", id: :serial, force: :cascade do |t|
    t.date "stated_on"
    t.date "posted_on"
    t.integer "account_id"
    t.string "account_code"
    t.string "currency_code"
    t.string "kind"
    t.decimal "beginning_balance"
    t.decimal "pnl_futures"
    t.decimal "ledger_balance"
    t.decimal "open_trade_equity"
    t.decimal "cash_account_balance"
    t.decimal "net_liquidating_balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "currency_mark"
    t.decimal "adjustments"
    t.string "segregation_code", null: false
    t.decimal "charges"
    t.index ["account_id", "stated_on", "currency_code", "kind", "segregation_code"], name: "statement_money_lines_uq", unique: true
  end

  create_table "statement_position_nettings", id: :serial, force: :cascade do |t|
    t.date "stated_on"
    t.date "posted_on"
    t.integer "account_id"
    t.string "account_code"
    t.string "claim_code"
    t.string "claim_name"
    t.string "netting_code"
    t.string "bot_price_traded"
    t.string "sld_price_traded"
    t.decimal "done"
    t.decimal "pnl"
    t.string "currency_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_code"], name: "index_statement_position_nettings_on_account_code"
    t.index ["claim_code"], name: "index_statement_position_nettings_on_claim_code"
    t.index ["posted_on"], name: "index_statement_position_nettings_on_posted_on"
  end

  create_table "statement_positions", id: :serial, force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "account_code", null: false
    t.string "claim_code", null: false
    t.string "claim_name", null: false
    t.date "stated_on", null: false
    t.date "posted_on", null: false
    t.date "traded_on", null: false
    t.decimal "bot", null: false
    t.decimal "sld", null: false
    t.decimal "net", null: false
    t.decimal "price", null: false
    t.decimal "mark", null: false
    t.decimal "ote", null: false
    t.string "currency_code", null: false
    t.string "position_status_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "price_traded"
    t.index ["account_code", "claim_code", "posted_on", "traded_on", "price"], name: "statement_positions_uq"
  end

  create_table "system_types", id: :serial, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "system_type_code_uq", unique: true
    t.index ["name"], name: "system_type_name_uq", unique: true
  end

  create_table "systems", id: :serial, force: :cascade do |t|
    t.integer "entity_id", null: false
    t.integer "system_type_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "system_code_uq", unique: true
    t.index ["name"], name: "system_name_uq", unique: true
  end

  create_table "user_duties", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "duty_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["duty_id"], name: "index_user_duties_on_duty_id"
    t.index ["user_id", "duty_id"], name: "index_user_duties_on_user_id_and_duty_id", unique: true
    t.index ["user_id"], name: "index_user_duties_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "view_points", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "note"
    t.text "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "account_aliases", "accounts"
  add_foreign_key "account_aliases", "systems"
  add_foreign_key "account_portfolios", "accounts"
  add_foreign_key "account_portfolios", "portfolios"
  add_foreign_key "accounts", "account_types", name: "account_account_type_fk"
  add_foreign_key "accounts", "entities", name: "account_entity_fk"
  add_foreign_key "adjustments", "accounts", name: "adjustment_account_fk"
  add_foreign_key "adjustments", "adjustment_types", name: "adjustment_adjustment_type_fk"
  add_foreign_key "adjustments", "journal_entries", name: "adjustment_journal_entry_fk"
  add_foreign_key "adjustments", "segregations"
  add_foreign_key "chargeables", "chargeable_types", name: "chargeables_chargeable_types_fk"
  add_foreign_key "chargeables", "claim_sets", name: "chargeables_claim_sets_fk"
  add_foreign_key "chargeables", "currencies", name: "chargeables_currencies_fk"
  add_foreign_key "charges", "accounts", name: "charges_accounts_fk"
  add_foreign_key "charges", "chargeables", name: "charges_chargeables_fk"
  add_foreign_key "charges", "currencies", name: "charges_currencies_fk"
  add_foreign_key "charges", "journal_entries", name: "charges_journal_entries_fk"
  add_foreign_key "charges", "segregations", name: "charges_segregations_fk"
  add_foreign_key "claim_aliases", "claims", name: "claim_alias_claim_fk"
  add_foreign_key "claim_aliases", "systems", name: "claim_alias_system_fk"
  add_foreign_key "claim_marks", "claims", name: "claim_mark_claim_fk"
  add_foreign_key "claim_marks", "systems", name: "claim_mark_system_fk"
  add_foreign_key "claim_set_aliases", "claim_sets", name: "claim_set_alias_claim_set_fk"
  add_foreign_key "claim_set_aliases", "systems", name: "claim_set_alias_system_fk"
  add_foreign_key "claims", "claim_sets", name: "claim_claim_set_fk"
  add_foreign_key "claims", "claim_types", name: "claim_claim_type_fk"
  add_foreign_key "claims", "currencies", column: "point_currency_id", name: "claim_point_currency_fk"
  add_foreign_key "claims", "entities", name: "claim_entity_fk"
  add_foreign_key "clearing_venues", "clearing_venue_types", name: "clearing_venue_clearing_venue_type_fk"
  add_foreign_key "clearing_venues", "entities", name: "clearing_venue_entity_fk"
  add_foreign_key "deal_leg_fills", "accounts", name: "fill_account_fk"
  add_foreign_key "deal_leg_fills", "booker_reports", name: "fill_booker_report_fk"
  add_foreign_key "deal_leg_fills", "claims", name: "fill_claim_fk"
  add_foreign_key "deal_leg_fills", "deal_legs", name: "fill_to_leg_fk"
  add_foreign_key "deal_leg_fills", "dealing_venues", name: "fill_to_dealing_venue_fk"
  add_foreign_key "deal_leg_fills", "positions", name: "fill_position_fk"
  add_foreign_key "deal_leg_fills", "systems", name: "fill_system_fk"
  add_foreign_key "deal_legs", "claims", name: "deal_leg_claim_fk"
  add_foreign_key "deal_legs", "deals", name: "deal_leg_deal_fk"
  add_foreign_key "dealing_venue_aliases", "dealing_venues", name: "dealing_venue_aliase_dealing_venue_fx"
  add_foreign_key "dealing_venue_aliases", "systems", name: "dealing_venue_aliases_system_fx"
  add_foreign_key "dealing_venues", "dealing_venue_types", name: "dealing_venue_dealing_venue_type_fk"
  add_foreign_key "dealing_venues", "entities", name: "dealing_venue_entity_type_fk"
  add_foreign_key "deals", "accounts", name: "deal_account_fk"
  add_foreign_key "deals", "deal_types", name: "deal_deal_type_fk"
  add_foreign_key "entities", "entity_types", name: "entity_entity_type_fk"
  add_foreign_key "entity_aliases", "entities", name: "entity_alias_entity_fk"
  add_foreign_key "entity_aliases", "systems", name: "entity_alias_system_fk"
  add_foreign_key "entity_roles", "entities", name: "entity_role_entity_fk"
  add_foreign_key "entity_roles", "roles", name: "entity_role_role_fk"
  add_foreign_key "fill_charge_journal_entries", "charges", name: "fill_charge_journal_entries_charges_fk"
  add_foreign_key "fill_charge_journal_entries", "deal_leg_fills", name: "fill_charge_journal_entries_fills_fk"
  add_foreign_key "fill_charge_journal_entries", "journal_entries", name: "fill_charge_journal_entries_journal_entries_fk"
  add_foreign_key "futures", "claims", column: "claimable_id", name: "future_claimable_fk"
  add_foreign_key "journal_entries", "accounts", name: "journal_entry_account_fk"
  add_foreign_key "journal_entries", "journal_entry_types", name: "journal_entry_journal_entry_type_fk"
  add_foreign_key "journal_entries", "journals", name: "journal_entry_journal_fk"
  add_foreign_key "journal_entries", "segregations"
  add_foreign_key "journals", "journal_types", name: "journal_journal_type_fk"
  add_foreign_key "ledger_entries", "accounts", name: "ledger_entry_account_fk"
  add_foreign_key "ledger_entries", "currencies", name: "ledger_entry_currency_fk"
  add_foreign_key "ledger_entries", "ledger_entry_types", name: "ledger_entry_ledger_entry_type_fk"
  add_foreign_key "ledger_entries", "ledgers", name: "ledger_entry_ledger_fk"
  add_foreign_key "ledger_entries", "segregations"
  add_foreign_key "ledgers", "ledger_types", name: "ledger_ledger_type_fk"
  add_foreign_key "managed_accounts", "accounts", name: "managed_account_account_fk"
  add_foreign_key "managed_accounts", "users", name: "managed_account_user_fk"
  add_foreign_key "margin_requests", "margin_request_statuses"
  add_foreign_key "margin_requests", "margins"
  add_foreign_key "margin_responses", "margin_requests"
  add_foreign_key "margin_responses", "margin_response_statuses"
  add_foreign_key "margins", "currencies"
  add_foreign_key "margins", "margin_calculators"
  add_foreign_key "margins", "margin_statuses"
  add_foreign_key "margins", "portfolios"
  add_foreign_key "money_lines", "currencies", name: "money_line_ccy_base_fk"
  add_foreign_key "money_lines", "segregations"
  add_foreign_key "monies", "claims", column: "claimable_id", name: "money_claimable_fk"
  add_foreign_key "portfolio_positions", "portfolios"
  add_foreign_key "portfolio_positions", "positions"
  add_foreign_key "position_nettings", "accounts", name: "position_netting_account_fk"
  add_foreign_key "position_nettings", "claims", name: "position_netting_claim_fk"
  add_foreign_key "position_nettings", "currencies", name: "position_netting_currency_fk"
  add_foreign_key "position_nettings", "position_netting_types", name: "position_netting_type_fk"
  add_foreign_key "position_nettings", "positions", column: "bot_position_id", name: "bot_position_fk"
  add_foreign_key "position_nettings", "positions", column: "sld_position_id", name: "sld_position_fk"
  add_foreign_key "position_transfers", "positions", column: "fm_position_id", name: "position_transfers_fm_position_fk"
  add_foreign_key "position_transfers", "positions", column: "to_position_id", name: "position_transfers_to_position_fk"
  add_foreign_key "position_transfers", "users", name: "position_transfer_user_fk"
  add_foreign_key "positions", "accounts", name: "positions_accounts_fk"
  add_foreign_key "positions", "claims", name: "positions_claims_fk"
  add_foreign_key "positions", "currencies", name: "positions_currencies_fk"
  add_foreign_key "positions", "position_statuses", name: "positions_position_status_fk"
  add_foreign_key "report_type_report_type_parameters", "report_type_parameters", name: "report_type_report_type_parameters_fk_02"
  add_foreign_key "report_type_report_type_parameters", "report_types", name: "report_type_report_type_parameters_fk_01"
  add_foreign_key "reports", "format_types"
  add_foreign_key "reports", "report_types"
  add_foreign_key "spread_legs", "claims"
  add_foreign_key "spread_legs", "spreads"
  add_foreign_key "spreads", "claims", column: "claimable_id", name: "spread_claimable_fk"
  add_foreign_key "statement_adjustments", "accounts"
  add_foreign_key "statement_commissions", "accounts"
  add_foreign_key "statement_deal_leg_fills", "accounts", name: "statement_deal_leg_fill_account"
  add_foreign_key "statement_fees", "accounts"
  add_foreign_key "statement_money_lines", "accounts", name: "statement_money_line_account_fk"
  add_foreign_key "statement_position_nettings", "accounts", name: "statement_position_netting_account_fk"
  add_foreign_key "statement_positions", "accounts"
  add_foreign_key "systems", "entities", name: "system_entity_fk"
  add_foreign_key "systems", "system_types", name: "system_system_type_fk"
  add_foreign_key "user_duties", "duties"
  add_foreign_key "user_duties", "users"
end
