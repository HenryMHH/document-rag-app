class User < ApplicationRecord
  has_many :documents, dependent: :destroy
end
