class Chat < ApplicationRecord
  belongs_to :user
  has_many :messages, dependent: :destroy, inverse_of: :chat
end
