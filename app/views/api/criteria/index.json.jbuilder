json.data @criteria do |criterion|
  json.partial! 'api/criteria/criterion', criterion: criterion
end
