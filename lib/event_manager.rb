require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = 'e179a6973728c4dd3fb1204283aaccb5'
template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

puts "EventManager Initialized"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode).join(", ")

  form_letter = erb_template.result(binding)

  puts form_letter

end
