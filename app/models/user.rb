class User < ApplicationRecord
  has_many :documents, dependent: :nullify
  belongs_to :role
end
