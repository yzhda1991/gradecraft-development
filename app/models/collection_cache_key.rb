class CollectionCacheKey
  def self.cache_key(collection)
    digest = Digest::MD5.new
    collection.each do |item|
      digest << "#{item.id}-#{item.updated_at}"
    end
    "#{collection.class.name.underscore}/#{digest.hexdigest}"
  end
end
