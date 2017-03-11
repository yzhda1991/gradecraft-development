json.array! @courses do |course|
  json.merge! course.attributes
end
