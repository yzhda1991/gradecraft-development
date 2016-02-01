module S3Manager
  class Manager
    include S3Manager::Basics
    include S3Manager::Encryption
    include S3Manager::Kms
    include S3Manager::ObjectSummary
    include S3Manager::Common
  end
end
