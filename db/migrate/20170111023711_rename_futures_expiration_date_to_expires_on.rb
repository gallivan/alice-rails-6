class RenameFuturesExpirationDateToExpiresOn < ActiveRecord::Migration[5.2]
  def change
    rename_column :futures, :expiration_date, :expires_on
  end
end
