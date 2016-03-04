REGEX = {
  # this is the regex for testing UUID formatting
  "UUID" => /\A[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}\z/,

  # regex for testing formatting of 190-bit secure keys, 254 characters
  "190_BIT_SECRET_KEY" => /[a-zA-Z0-9_\-]{254}/,

  # regex for testing formatting of 512-bit secure encrypted keys, 1049 or 1050 characters
  "512_BIT_ENCRYPTED_KEY" => /\A[a-f0-9\$]{1049,1050}\z/
}
