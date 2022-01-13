class AddGroupIdToAccount < ActiveRecord::Migration[5.2]
  def up
    add_column :accounts, :group_id, :integer
    add_index :accounts, [:id, :group_id], unique: true

    AccountType.create! do |t|
      t.code = 'GRP'
      t.name = 'Group Account'
    end
  end

  def down
    AccountType.where(code: 'GRP').delete_all
    remove_column :accounts, :group_id, :integer
  end
end
