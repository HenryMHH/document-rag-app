module V1
  module Entities
    class User < Grape::Entity
      expose :id
      expose :name
      expose :email
      expose :avatar_url
      expose :role do |user|
        user.role.name
      end
    end
  end
end
