class Role
  ROLES = %w(student professor gsi admin observer) unless defined? ROLES

  def self.all
    ROLES.freeze
  end

  def self.all_with_staff
    all + ["staff"]
  end
end
