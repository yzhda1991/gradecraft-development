module RandomFile
  class TextFile
    def initialize(file_path)
      @file_path = file_path
    end
    attr_reader :file_path

    def random_string(scale=10000)
      @random_string = (0..(rand(scale) + scale)).map do
        (65 + rand(26)).chr
      end.join
    end

    def write
      File.open(file_path, "wt") {|file| file.puts random_string }
    end

    def read
      File.readlines(file_path)
    end

    def size
      File.stat(file_path).size
    end

    def delete
      FileUtils.rm(file_path)
    end

    def exist?
      File.exist?(file_path)
    end
  end
end
