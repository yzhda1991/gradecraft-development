json.data @criteria do |criterion|
  json.partial! 'api/criteria/criterion', criterion: criterion
end

json.included do
  json.array! @levels do |level|
    json.partial! 'api/levels/level', level: level
  end
end
