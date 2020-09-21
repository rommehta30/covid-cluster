class CreateHexagons < ActiveRecord::Migration[6.0]
  def change
    create_table :hexagons do |t|
      t.string :name, null: false, unique: true
      t.boolean :is_covid_cluster
      t.json :sides, default: {}

      t.timestamps
    end
  end
end
