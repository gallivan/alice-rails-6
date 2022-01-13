class CreateMarginCalculators < ActiveRecord::Migration[5.2]
  def up
    create_table :margin_calculators do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :note

      t.timestamps null: false
    end

    MarginCalculator.create! do |c|
      c.code = 'CME_CORE'
      c.name = 'CME Core'
    end
  end

  def down
    drop_table :margin_calculators
  end
end
