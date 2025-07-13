class User < ApplicationRecord
  has_many :documents, dependent: :destroy
  belongs_to :role
end
