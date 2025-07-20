class Message < ApplicationRecord
  belongs_to :chat

  # 驗證 role 欄位必須存在且為預設值之一
  validates :role, presence: true, inclusion: { in: %w[user assistant tool developer] }
  # 移除了 'system' role，因為在 chat_history 範例中沒有看到，如果你需要可以再加回去

  # content 欄位在某些情況下可以為空
  # 1. 如果角色是 'assistant' 且有 tool_calls (表示回應主要來自工具調用，而非直接文字)
  # 2. 如果角色是 'tool' (tool 訊息的 content 是工具執行結果，也可能是空或只有特定格式)
  validates :content, presence: true, unless: lambda {
    (role == "assistant" && tool_calls.present?) || (role == "tool")
  }

  # 驗證 tool_calls 的存在性
  # 只有當 role 是 'assistant' 時，才可能會有 tool_calls
  validates :tool_calls, presence: true, if: lambda {
    role == "assistant" && content.blank? && annotations.blank?
    # 如果 assistant 的 content 和 annotations 都為空，那通常應該有 tool_calls
  }

  # 驗證 tool_call_id 和 name 的存在性
  # 只有當 role 是 'tool' 時，才需要這兩個欄位
  validates :tool_call_id, presence: true, if: -> { role == "tool" }

  # 額外考量：annotations 和 refusal
  # 這兩個欄位通常是可選的，不需要特別的驗證
  # 例如，你可以添加驗證，確保它們是有效的 JSON 格式，但由於是 jsonb 類型，Rails 會自動處理
  # validates :annotations, json: true # 如果你有安裝類似 `json_validator` gem
  # validates :tool_calls, json: true # 如果你有安裝類似 `json_validator` gem
end
