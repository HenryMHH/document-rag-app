class ChatService
  def initialize
    @openai_client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
  end

  def call(chat)
    messages = chat.messages.to_a.map do |message|
      case message.role
      # tool message
      when "tool"
        {
          role: message.role,
          content: message.content,
          tool_call_id: message.tool_call_id
        }
      # developer message
      when "developer"
        {
          role: message.role,
          content: message.content
        }
      # assistant message
      when "assistant"
        if message.tool_calls.length.positive?
          # function call message
          {
            role: message.role,
            content: message.content,
            refusal: message.refusal,
            annotations: message.annotations,
            tool_calls: message.tool_calls
          }
        else
          # assistant message without tool calls
          {
            role: message.role,
            content: message.content,
            refusal: message.refusal,
            annotations: message.annotations
          }
        end
      # user message
      when "user"
        {
          role: message.role,
          content: message.content
        }
      end
    end

    # return messages

    response = @openai_client.chat.completions.create(
      messages: messages,
      model: :"gpt-4.1-nano",
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

    if message[:tool_calls]
      tool_call = message[:tool_calls].first
      function_name = tool_call[:function][:name]
      arguments = JSON.parse(tool_call[:function][:arguments])

      if function_name == "search_document"
        function_result = search_document(arguments["search_message"])

        function_result = "I can't find any information about that" if function_result.strip.empty?

        chat.messages.create(message.to_h)

        messages << message

        tool_message = {
          role: "tool",
          tool_call_id: tool_call[:id],
          content: function_result
        }

        messages << tool_message

        chat.messages.create(tool_message.to_h)

        final_response = @openai_client.chat.completions.create(
          messages: messages,
          model: :"gpt-4.1-nano"
        )

        final_message = final_response[:choices][0][:message]

        messages << final_message

        chat.messages.create(final_message.to_h)

        final_message[:content]
      end
    else
      chat.messages.create(message.to_h)

      message[:content]
    end
  end

  def get_document_title(user_message)
    response = @openai_client.chat.completions.create(
      messages: [
        { role: "user", content: "please generate a title for the following message: #{user_message}" }
      ],
      model: :"gpt-4.1-nano"
    )

    response[:choices][0][:message][:content]
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
