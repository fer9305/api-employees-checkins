json.employees @employees do |employee|
  json.id employee.id
  json.first_name employee.first_name
  json.last_name employee.last_name
end