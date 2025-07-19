class DocumentChunk < ApplicationRecord
  belongs_to :document
  has_neighbors :embedding, dimensions: 1536

  def self.search_by_embedding(query_embedding, distance_threshold = 0.7, result_limit = 5)
    sql_template = <<-SQL
          -- CTE definition to avoid sql injection
          WITH ranked_chunks AS (
            SELECT
              document_chunks.*,
              (embedding <=> :query_vector::vector) AS distance
            FROM
              document_chunks
          )
          SELECT
            *
          FROM
            ranked_chunks
          WHERE
            distance < :threshold
          ORDER BY
            distance ASC
          LIMIT
            :limit
    SQL

    find_by_sql([
                  sql_template, # 第一個元素是樣板
                  { # 第二個元素是包含所有值的 Hash
                    query_vector: query_embedding.to_json,
                    threshold: distance_threshold,
                    limit: result_limit
                  }
                ])
  end
end
