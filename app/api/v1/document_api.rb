require "openai"

OPENAI_API_KEY = ENV["OPENAI_API_KEY"]

module V1
  # Document api
  class DocumentApi < BaseApi
    before do
      authenticate_user!
    end

    resource :document do
      desc "Get all documents"
      get "/all" do
        documents = Document.all
        present documents, with: Entities::Document
      end

      desc "Create document"
      params do
        requires :file, type: File, desc: "Document file"
      end
      post "/create" do
        uploaded_file = params[:file]
        user = current_user

        tempfile = uploaded_file["tempfile"] || uploaded_file[:tempfile]
        filename = uploaded_file["filename"] || uploaded_file[:filename]
        content_type = uploaded_file["type"] || uploaded_file[:type]

        file_path = tempfile.path if tempfile.respond_to?(:path)

        Rails.logger.info "Processing file: #{filename}"
        Rails.logger.info "File path: #{file_path}"
        Rails.logger.info "Content type: #{content_type}"

        pdf = PDF::Reader.new(file_path)

        document = Document.create!(
          user: user,
          title: filename || "Untitled",
          original_filename: filename || "unknown.pdf",
          file_type: content_type || "application/pdf",
          total_pages: pdf.pages.count
        )

        # 要轉換的文本
        text_to_embed = pdf.pages.map(&:text)

        headers = {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{OPENAI_API_KEY}"
        }

        if defined?(Faraday)
          conn = Faraday.new(url: "https://api.openai.com") do |f|
            f.request :json
            f.response :json
            f.adapter Faraday.default_adapter
          end

          begin
            response = conn.post("v1/embeddings") do |req|
              req.headers = headers
              req.body = {
                model: "text-embedding-3-small",
                input: text_to_embed
              }
            end

            if response.success?
              response.body["data"].map do |data|
                DocumentChunk.create!(
                  document: document,
                  content: text_to_embed[data["index"]],
                  embedding: data["embedding"],
                  chunk_order: data["index"]
                )
              end
            else
              puts "API 請求失敗 (Faraday): #{response.status}"
              puts "錯誤訊息: #{response.body}"
            end
          rescue StandardError => e
            puts "發生錯誤 (Faraday): #{e.message}"
          end
        else
          puts "未安裝 Faraday Gem。如果想使用 Faraday，請將 gem 'faraday' 加入 Gemfile 並執行 bundle install。"
        end

        {
          message: "Document created successfully",
          document_id: document.id
        }
      end
    end
  end
end
