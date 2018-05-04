json.data @ungraded_submissions do |submission|
  json.type "submissions"
  json.id submission.id.to_s

  json.attributes do
    json.id submission.id.to_s
  end
end

json.meta do
  json.term_for_assignment term_for :assignment
end
