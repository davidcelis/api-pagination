module ApiPagination
  class Version
    MAJOR = 4
    MINOR = 4
    PATCH = 0

    def self.to_s
      [MAJOR, MINOR, PATCH].join('.')
    end
  end

  VERSION = Version.to_s
end
