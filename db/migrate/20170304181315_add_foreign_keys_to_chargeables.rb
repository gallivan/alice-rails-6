class AddForeignKeysToChargeables < ActiveRecord::Migration[5.2]
  def up
    add_foreign_key :chargeables, :chargeable_types, column: :chargeable_type_id, name: :chargeables_chargeable_types_fk
    add_foreign_key :chargeables, :claim_sets, column: :claim_set_id, name: :chargeables_claim_sets_fk
    add_foreign_key :chargeables, :currencies, column: :currency_id, name: :chargeables_currencies_fk
  end

  def down
    remove_foreign_key :chargeables, :currencies
    remove_foreign_key :chargeables, :claim_sets
    remove_foreign_key :chargeables, :chargeable_types
  end
end
