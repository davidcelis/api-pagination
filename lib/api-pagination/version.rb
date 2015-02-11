module ApiPagination
  class Version
    MAJOR = 4
    MINOR = 1
    PATCH = 1

    def self.to_s
      [MAJOR, MINOR, PATCH].join('.')
    end
  end

  VERSION = Version.to_s
end
