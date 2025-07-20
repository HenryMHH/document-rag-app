class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :chat, null: false, foreign_key: true, type: :uuid
      t.string :role
      t.text :content
      t.string :function_name
      t.jsonb :function_arguments

      t.timestamps
    end
  end
end
