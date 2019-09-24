json.last_name @employee.last_name
json.first_name @employee.first_name
json.check_ins @check_ins do |check_in|
  json.begin_time check_in.begin_time
  json.end_time check_in.end_time
end
