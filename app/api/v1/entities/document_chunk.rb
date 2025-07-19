module V1
  module Entities
    class DocumentChunk < Grape::Entity
      expose :id
      expose :content
      expose :chunk_order
      expose :distance, if: ->(object, _) { object.distance.present? } do |object|
        object.distance.round(4)
      end
    end
  end
end
