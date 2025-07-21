class FileStorageService
  def initialize
    @storage = ActiveStorage::Blob.service
  end

  def upload(file)
    @storage.upload(file)
  end
end
