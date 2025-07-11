class CreateDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :documents do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :original_filename
      t.string :file_type
      t.integer :total_pages

      t.timestamps
    end
  end
end
