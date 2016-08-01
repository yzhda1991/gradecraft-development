require_relative "basics"
require_relative "encryption"
require_relative "kms"
require_relative "object_summary"
require_relative "common"

module S3Manager
  class Manager
    include S3Manager::Basics
    include S3Manager::Encryption
    include S3Manager::Kms
    include S3Manager::ObjectSummary
    include S3Manager::Common
  end
end
