class Dune
  class Client
    attr_accessor :api_key, :connection, :logger

    def initialize(api_key:, faraday_settings: {}, logger: Logger.new(IO::NULL))
      @api_key    = api_key
      @connection = Faraday.new(default_faraday_settings.merge(faraday_settings))
      @logger     = logger
    end

    def query(id, body = nil, headers = nil, &block)
      logger.debug("#{self} #{__method__} with #{id}")
      parse(connection.post("query/#{id}/execute", body, headers, &block))
    end

    def execution_status(id, params = nil, headers = nil, &block)
      logger.debug("#{self} #{__method__} with #{id}")
      parse(connection.get("execution/#{id}/status", params, headers, &block))
    end

    def execution(id, params = nil, headers = nil, &block)
      logger.debug("#{self} #{__method__} with #{id}")
      parse(connection.get("execution/#{id}/results", params, headers, &block))
    end

    def cancel(id, params = nil, headers = nil, &block)
      logger.debug("#{self} #{__method__} with #{id}")
      parse(connection.post("execution/#{id}/cancel", params, headers, &block))
    end

    private

    def parse(response)
      if (200..299).include?(response.status)
        JSON.parse(response.body)
      else
        error          = Dune::Error.new("Dune API replied with status #{response.status}")
        error.response = response
        logger.error(error)
        raise error
      end
    end

    def default_faraday_settings
      {
        url: Dune::BASE_URL,
        headers: {
          "Content-Type":   "application/json",
          "x-dune-api-key": api_key
        }
      }
    end
  end
end
