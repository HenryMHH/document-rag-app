module V1
  # Base api for all api v1
  class BaseApi < Grape::API
    include ApiAuthentication

    version "v1", using: :path
    format :json

    mount UserApi
    mount AuthApi
    mount DocumentApi
  end
end
