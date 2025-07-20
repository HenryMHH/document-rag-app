require_relative "../helpers/jwt_helper"

module V1
  # Base api for all api v1
  class BaseApi < Grape::API
    include ApiAuthentication

    helpers JwtHelper

    version "v1", using: :path
    format :json

    mount UserApi
    mount AuthApi
    mount DocumentApi
    mount ChatApi
  end
end
