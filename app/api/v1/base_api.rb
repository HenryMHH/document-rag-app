module V1
  # Base api for all api v1
  class BaseApi < Grape::API
    version "v1", using: :path
    format :json

    mount UserApi
    mount AuthApi
  end
end
