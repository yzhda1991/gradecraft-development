json.type "submission"
json.id @submission.id.to_s

json.attributes do
  json.merge! @submission.attributes
end
