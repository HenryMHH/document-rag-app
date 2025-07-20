class User < ApplicationRecord
  has_many :documents, dependent: :nullify
  has_many :chats, dependent: :destroy
  belongs_to :role
end
