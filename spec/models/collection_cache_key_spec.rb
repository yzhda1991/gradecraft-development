require "rspec/core"
require "./app/models/collection_cache_key"

describe CollectionCacheKey do
  let(:node1) { double(:node, id: 1, updated_at: DateTime.now) }
  let(:node2) { double(:node, id: 2, updated_at: DateTime.now) }
  let(:collection) { [node1, node2] }
  before { allow_any_instance_of(String).to receive(:underscore).and_return "array" }

  it "contains the class name" do
    cache_key = CollectionCacheKey.cache_key collection
    expect(cache_key).to include "array"
  end

  it "contains an md5 digest of the ids and timestamps" do
    cache_key = CollectionCacheKey.cache_key collection
    digest = Digest::MD5.new
    digest << "1-#{node1.updated_at}"
    digest << "2-#{node2.updated_at}"
    expect(cache_key).to include digest.hexdigest
  end
end
