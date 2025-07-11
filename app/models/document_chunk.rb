class DocumentChunk < ApplicationRecord
  belongs_to :document
  has_neighbors :embedding, dimensions: 1536
end
