module S3fs
  class << self
    def mktmpdir
      Dir.mktmpdir nil, tmpdir_prefix
    end

    def available?
      # check whether we need to use S3fs
      %w[staging production].include? Rails.env
    end

    def tmpdir_prefix
      # if we do use the prefix for the s3fs tempfiles
      available? ? "/s3mnt/tmp/#{Rails.env}" : nil
    end
  end
end
