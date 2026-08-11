class AddStationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :station, :string
  end
end
