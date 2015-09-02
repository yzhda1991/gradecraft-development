class Role
  ROLES = %w(student professor gsi admin)

  def self.all
    ROLES.freeze
  end

  def self.all_with_staff
    all + ["staff"]
  end
end
