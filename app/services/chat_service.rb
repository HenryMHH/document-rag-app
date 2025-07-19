class ChatService
  def initialize
    @openai_client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
  end

  def call(user_message)
    messages = [{ role: "user", content: user_message }]

    response = @openai_client.chat.completions.create(
      messages: messages,
      model: :"gpt-4.1-mini",
      "tools": [
        {
          "type": "function",
          "function": {
            "name": "search_document",
            "description": "Search the knowledge base for a given message.",
            "parameters": {
              "type": "object",
              "properties": {
                "search_message": {
                  "type": "string",
                  "description": "The message to search for in the knowledge base"
                }
              },
              "required": [
                "search_message"
              ],
              "additionalProperties": false
            },
            "strict": true
          }
        }
      ],
      "tool_choice": "auto"
    )

    message = response[:choices][0][:message]

    puts "message: #{message}"

    if message[:tool_calls]
      tool_call = message[:tool_calls].first
      function_name = tool_call[:function][:name]
      arguments = JSON.parse(tool_call[:function][:arguments])

      if function_name == "search_document"
        # 執行本地函式，現在這個函式變得非常乾淨
        function_result = search_document(arguments["search_message"])

        messages << message
        messages << {
          role: "tool",
          tool_call_id: tool_call[:id],
          name: function_name,
          content: function_result
        }

        puts "--- [Step 3] Sending tool result back to OpenAI for final answer... ---"
        final_response = @openai_client.chat.completions.create(
          messages: messages,
          model: :"gpt-4.1-mini"
        )
        final_response[:choices][0][:message][:content]
      end
    else
      puts "--- [Step 2] OpenAI answered directly. ---"
      message[:content]
    end
  end

  private

  def search_document(user_message)
    query_embedding = @openai_client.embeddings.create(
      input: user_message,
      model: "text-embedding-3-small"
    )[:data][0][:embedding]

    all_document_ids = DocumentChunk.search_by_embedding(query_embedding).map(&:document_id)

    id_counts = all_document_ids.tally

    max_count = id_counts.values.max

    top_document_ids = id_counts.select { |_, count| count == max_count }.keys

    Document.where(id: top_document_ids).map(&:title).join("\n")
  end
end
