json.data @unlock_conditions do |uc|
  json.type "unlock_condition"
  json.id uc.id

  json.attributes do
    json.merge! uc.attributes
  end
end
