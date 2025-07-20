class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
