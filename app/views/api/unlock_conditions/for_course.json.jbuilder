json.data @unlock_conditions do |unlock_condition|
  json.attributes do
    json.merge! unlock_condition.attributes
    json.requirements_description unlock_condition.requirements_description_sentence
    json.key_description unlock_condition.key_description_sentence
  end
end
