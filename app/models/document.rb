class Document < ApplicationRecord
  has_many :document_chunks, dependent: :destroy
  belongs_to :user
end
