class CreateMarginStatuses < ActiveRecord::Migration[5.2]
  def up
    create_table :margin_statuses do |t|
      t.string :code
      t.string :name

      t.timestamps null: false
    end

    MarginStatus.create! do |s|
      s.code = 'OPEN'
      s.name = 'Margin instance created'
    end

    MarginStatus.create! do |s|
      s.code = 'SENT'
      s.name = 'Computation requested'
    end

    MarginStatus.create! do |s|
      s.code = 'WORK'
      s.name = 'Computation working'
    end

    MarginStatus.create! do |s|
      s.code = 'DONE'
      s.name = 'Computation completed'
    end

    MarginStatus.create! do |s|
      s.code = 'FAIL'
      s.name = 'Computation failed'
    end
  end

  def down
    drop_table :margin_statuses
  end
end
