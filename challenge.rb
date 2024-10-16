require 'json'

# Read and parse the users and companies JSON files
def load_data(file)
  JSON.parse(File.read(file), symbolize_names: true)
end

# Process the companies and users data to produce the required output
def process_data(users, companies)
  File.open('output.txt', 'w') do |file|
    companies.sort_by { |company| company[:id] }.each do |company|
      file.puts "Company Id: #{company[:id]}"
      file.puts "Company Name: #{company[:name]}"
      
      emailed_users = []
      not_emailed_users = []
      total_top_up = 0

      users_for_company = users.select { |user| user[:company_id] == company[:id] && user[:active_status] }
      sorted_users = users_for_company.sort_by { |user| user[:last_name] }

      sorted_users.each do |user|
        new_token_balance = user[:tokens] + company[:top_up]
        total_top_up += company[:top_up]

        user_info = <<-USER_INFO
  #{user[:last_name]}, #{user[:first_name]}, #{user[:email]}
    Previous Token Balance, #{user[:tokens]}
    New Token Balance #{new_token_balance}
  USER_INFO

        if user[:email_status] && company[:email_status]
          emailed_users << user_info
        else
          not_emailed_users << user_info
        end
      end

      file.puts "Users Emailed:"
      emailed_users.each { |info| file.puts info }
      file.puts "Users Not Emailed:"
      not_emailed_users.each { |info| file.puts info }

      file.puts "Total amount of top ups for #{company[:name]}: #{total_top_up}"
      file.puts
    end
  end
end

# Entry point for the script
def main
  begin
    users = load_data('users.json')
    companies = load_data('companies.json')
    process_data(users, companies)
    puts 'Output written to output.txt'
  rescue Errno::ENOENT => e
    puts "File not found: #{e.message}"
  rescue JSON::ParserError => e
    puts "Invalid JSON format: #{e.message}"
  rescue => e
    puts "An error occurred: #{e.message}"
  end
end

# Run the script
main
