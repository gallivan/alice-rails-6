class CreateMarginResponseStatuses < ActiveRecord::Migration[5.2]
  def up
    create_table :margin_response_statuses do |t|
      t.string :code
      t.string :name

      t.timestamps null: false
    end

    MarginResponseStatus.create! do |s|
      s.code = 'OPEN'
      s.name = 'Response open'
    end

    MarginResponseStatus.create! do |s|
      s.code = 'DONE'
      s.name = 'Response done'
    end

    MarginResponseStatus.create! do |s|
      s.code = 'FAIL'
      s.name = 'Response fail'
    end
  end

  def down
    drop_table :margin_response_statuses
  end
end
