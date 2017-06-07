class StudentSampleExporter
  def generate_csv(options={})
    CSV.generate(options) do |csv|
      csv << user_headers
      csv << user_a_details
      csv << user_b_details
    end
  end

  private

  def user_headers
    ["First Name", "Last Name", "Username", "Email", "Team Name"].freeze
  end

  def user_a_details
    ["John", "Doe", "johnd", "johnd@school.edu", "Team Doe"].freeze
  end

  def user_b_details
    ["Jane", "Doe", "janed", "janed@school.edu", "Team Doe"].freeze
  end
  
end
