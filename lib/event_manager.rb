require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

def clean_phone(phone_number)
  phone_number = phone_number.to_s
  if phone_number.length < 10
   "Incorrect phone number"
  elsif phone_number.length == 10
     phone_number 
  elsif phone_number.length == 11 && phone_number[0] == 1
    phone_number = phone_number[1..10]
    phone_number
  elsif phone_number.length > 10
    "Invalid phone number"
  end
end
puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  phone_numbers = clean_phone(row[:homephone])
  
  form_letter = erb_template.result(binding)

  save_thank_you_letters(id,form_letter)
end
