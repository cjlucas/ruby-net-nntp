module Net
  class NNTPResponse
    PARSE_RE = /^(\d{3})\s*(.*)/

    # @todo change these to attr_reader
    # @return [String] the raw response
    attr_accessor :raw
    # @return [Integer] the response code
    attr_accessor :code
    # @return [String] the response message
    attr_accessor :message

    def self.parse(raw)
      new(raw).tap { |resp| resp.parse }
    end

    def initialize(raw)
      @raw = raw
    end

    def parse
      @code     = @raw[PARSE_RE, 1].to_i
      @message  = @raw[PARSE_RE, 2]
    end

    def has_long_response?
      false
    end

    def to_s
      "#{self.class} code: #{code} message: #{message}"
    end
  end

  NNTPOKResponse = Class.new(NNTPResponse)
  NNTPErrorResponse = Class.new(NNTPResponse)

  class NNTPLongResponse < NNTPOKResponse
    # @return [String] the raw multi-block data
    attr_reader :raw_data

    def has_long_response?
      true
    end

    def handle_long_response(data)
      @raw_data = data
    end
  end

end

require_relative 'response/responses'
