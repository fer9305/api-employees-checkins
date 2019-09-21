class CreateCheckIns < ActiveRecord::Migration[5.1]
  def change
    create_table :check_ins do |t|
      t.references :user, foreign_key: true
      t.datetime :begin_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
