module V1
  module Entities
    class Document < Grape::Entity
      expose :id
      expose :title
      expose :original_filename
      expose :file_type
      expose :total_pages
      expose :created_at
    end
  end
end
