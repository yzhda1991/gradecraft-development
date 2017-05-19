json.type "criteria"
json.id   criterion.id.to_s

json.attributes do
  json.merge! criterion.attributes

  json.relationships do
    json.levels do
      json.data criterion.levels do |level|
        json.type "levels"
        json.id level.id.to_s
      end
    end
  end
end


