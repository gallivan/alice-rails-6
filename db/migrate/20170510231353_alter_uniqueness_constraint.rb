class AlterUniquenessConstraint < ActiveRecord::Migration[5.2]
  def up
    remove_index :reports, name: :reports_uq
    add_index :reports, [:location], unique: true, name: :reports_uq
  end

  def down
    remove_index :reports, name: :reports_uq
    add_index :reports, [:report_type_id, :format_type_id, :posted_on], unique: true, name: :reports_uq
  end
end
