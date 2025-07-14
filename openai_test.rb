OPENAI_API_KEY = ENV["OPENAI_API_KEY"]

# 要轉換的文本
text_to_embed = PDF::Reader.new("lease-rental-agreement.pdf").pages.map(&:text)

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
      embedding = response.body["data"][0]["embedding"]
      puts "文本: '#{text_to_embed}'"
      puts "向量長度: #{embedding.length}"
      puts "前 5 個向量值: #{embedding.first(5).inspect}..."
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
