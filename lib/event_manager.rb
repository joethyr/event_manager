require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def clean_phone_numbers(number)
  number.gsub!(/[^\d]/, '')
  if number.length == 10
    number
  elsif number.length == 11 && number[0] == '1'
    number[1..11]
  else
    'bad number'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

def contents
  CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
  )
end

def reg_datetime(regex)
  reg_date_array = []
  contents.each do |row|
    reg_date = row[:regdate]
    reg_datetime = Time.strptime(reg_date, '%M/%d/%y %k:%M').strftime(regex)
    reg_date_array.push(reg_datetime)
  end
  most_common_datetime(reg_date_array)
end

def most_common_datetime(reg_date_array)
  most_common_datetime = reg_date_array.reduce(Hash.new(0)) do |key, value|
    key[value] += 1
    key
  end
  most_common_datetime.max_by { |_k, v| v }[0]
end

puts "\nThe most common hour of registration is hour #{reg_datetime('%k')}:00."
puts "\nThe most common day of registration is #{reg_datetime('%A')}."

# template_letter = File.read('form_letter.erb')
# erb_template = ERB.new template_letter

# contents.each do |row|
#   id = row[0]
#   name = row[:first_name]
#   zipcode = clean_zipcode(row[:zipcode])
#   legislators = legislators_by_zipcode(zipcode)
#   phone_number = clean_phone_numbers(row[:homephone])
#   form_letter = erb_template.result(binding)

#   save_thank_you_letter(id, form_letter)
# end
