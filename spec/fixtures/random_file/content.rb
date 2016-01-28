module RandomFile
  module Content
    def self.random_string(scale=10000)
      (0..(rand(scale) + scale)).map do
        (65 + rand(26)).chr
      end.join
    end
  end
end
