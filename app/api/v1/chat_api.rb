module V1
  class ChatApi < BaseApi
    before do
      authenticate_user!
    end

    resource :chat do
      params do
        requires :chat_id, type: String, desc: "Chat Id"
      end
      get "/" do
        chat = Chat.find_by(id: params[:chat_id], user_id: current_user.id)

        {
          chat_id: chat.id,
          title: chat.title,
          messages: chat.messages.select do |message|
            %w[user assistant].include?(message.role) && message.tool_calls.blank?
          end
        }
      end

      params do
        optional :chat_id, type: String, desc: "Chat Id"
        requires :message, type: String, desc: "Message"
      end
      post "/" do
        chat_service = ChatService.new

        chat = if params[:chat_id].present?
                 Chat.find_by(id: params[:chat_id], user_id: current_user.id)
               else
                 title = chat_service.get_document_title(params[:message])
                 c = Chat.create(user_id: current_user.id, title: title)
                 c.messages.create(
                   content: "As a dedicated legal document assistant, your mission is to expertly guide users to the most pertinent legal documents for their needs. My scope is strictly limited to legal document recommendations; I will politely decline to answer any questions outside of this domain.",
                   role: "developer"
                 )

                 c
               end

        chat.messages.create(
          content: params[:message],
          role: "user"
        )

        response = chat_service.call(chat)

        {
          chat_id: chat.id,
          title: chat.title,
          message: response
        }
      end
    end
  end
end
