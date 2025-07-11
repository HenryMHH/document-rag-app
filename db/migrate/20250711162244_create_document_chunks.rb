class CreateDocumentChunks < ActiveRecord::Migration[7.1]
  def change
    create_table :document_chunks do |t|
      t.references :document, null: false, foreign_key: true
      t.text :content
      t.integer :chunk_order

      t.column :embedding, :vector, limit: 1536

      t.timestamps
    end
  end
end
