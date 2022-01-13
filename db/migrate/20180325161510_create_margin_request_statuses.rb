class CreateMarginRequestStatuses < ActiveRecord::Migration[5.2]
  def up
    create_table :margin_request_statuses do |t|
      t.string :code
      t.string :name

      t.timestamps null: false
    end

    MarginRequestStatus.create! do |s|
      s.code = 'OPEN'
      s.name = 'Request open'
    end

    MarginRequestStatus.create! do |s|
      s.code = 'DONE'
      s.name = 'Request done'
    end

    MarginRequestStatus.create! do |s|
      s.code = 'FAIL'
      s.name = 'Request fail'
    end
  end

  def down
    drop_table :margin_request_statuses
  end
end
