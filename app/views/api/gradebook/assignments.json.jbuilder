json.data @assignments do |assignment|
  json.type "assignment"
  json.id assignment[:id]

  json.attributes do
    json.id assignment[:id]
    json.name assignment[:name]
  end
end
