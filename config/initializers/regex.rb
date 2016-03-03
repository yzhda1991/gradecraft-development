REGEX = {
  # this is the regex for testing UUID formatting
  "UUID" => /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/,

  # regex for testing formatting of 190-bit secure keys, 254 characters
  "190_BIT_SECRET_KEY" => /[a-zA-Z0-9_\-]{254}/
}
