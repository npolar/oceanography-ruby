module Oceanography
  class SanityValidator

    attr_reader :log

    def initialize(options)
      @log = options[:log]
    end

    def validate(data)
      begin
        errors = [min_date(data), max_date(data)].compact
      rescue => err
        errors = ["Sanity validation failed with #{err.message}"]
      end
      errors.each { |e| log.error("Validating #{data['id']} #{e}")}
      errors
    end

    def min_date(data)
      measured = data["measured"]
      measured = DateTime.parse(measured) if !measured.kind_of?(DateTime)
      if (measured <=> DateTime.civil(1900)) < 0
        "#{measured} is too far back in time."
      end
    end

    def max_date(data)
      measured = data["measured"]
      measured = DateTime.parse(measured) if !measured.kind_of?(DateTime)
      if (measured <=> DateTime.now) > 0
        "#{measured} is in the future."
      end
    end

  end
end
