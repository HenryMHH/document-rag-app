module V1
  # User api
  class UserApi < BaseApi
    resource :user do
      desc "Get user"
      get "/info" do
        user = authenticate_user!

        {
          id: user.id,
          name: user.name,
          email: user.email,
          avatar_url: user.avatar_url,
          role: user.role.name
        }
      end
    end
  end
end
