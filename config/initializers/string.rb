class String
  # Adapted from http://archive.jeffgardner.org/2011/08/04/rails-string-to-boolean-method/
  def to_boolean
    return true if self == true || self =~ (/^(true|t|yes|y|1)$/i)
    return false if self == false || self =~ (/^(false|f|no|n|0)$/i)
    return nil
  end
end
