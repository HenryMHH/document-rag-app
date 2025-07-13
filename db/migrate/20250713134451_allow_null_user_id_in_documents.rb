class AllowNullUserIdInDocuments < ActiveRecord::Migration[7.1]
  def change
    # 允许 user_id 可以为 null
    change_column_null :documents, :user_id, true

    # 移除旧的外键约束
    remove_foreign_key :documents, :users

    # 添加新的外键约束，设置删除时为 nullify
    add_foreign_key :documents, :users, on_delete: :nullify
  end
end
