class UpdateMessagesSchema < ActiveRecord::Migration[7.1]
  def change
    # 添加新的欄位
    add_column :messages, :refusal, :string, null: true
    add_column :messages, :annotations, :jsonb, null: false, default: []
    add_column :messages, :tool_calls, :jsonb, null: false, default: []
    add_column :messages, :tool_call_id, :string, null: true # 用於 'tool' 角色
    add_column :messages, :name, :string, null: true         # 用於 'tool' 角色 (工具名稱)

    # 移除舊的欄位
    remove_column :messages, :function_name, :string
    remove_column :messages, :function_arguments, :jsonb
  end
end
