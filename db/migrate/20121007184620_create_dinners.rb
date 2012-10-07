class CreateDinners < ActiveRecord::Migration
  def change
    create_table :dinners do |t|
      t.string :name

      t.timestamps
    end
  end
end
