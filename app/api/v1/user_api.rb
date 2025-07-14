module V1
  # User api
  class UserApi < BaseApi
    resource :user do
      desc "Get user"
      get "/info" do
        user = authenticate_user!

        present user, with: Entities::User
      end

      desc "Get all users"
      get "/all" do
        users = User.all.includes(:role)
        present users, with: Entities::User
      end
    end
  end
end
