require_relative 'basics'
require_relative 'encryption'
require_relative 'kms'

module S3Manager
  class Manager
    include S3Manager::Basics
    include S3Manager::Encryption
    include S3Manager::Kms
  end
end
