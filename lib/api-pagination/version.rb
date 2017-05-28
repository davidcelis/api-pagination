module ApiPagination
  class Version
    MAJOR = 4
    MINOR = 6
    PATCH = 3

    def self.to_s
      [MAJOR, MINOR, PATCH].join('.')
    end
  end

  VERSION = Version.to_s
end
