require 'date'

module Net
  class NNTPResponse
    PARSE_RE = /^(\d{3})\s*(.*)/

    attr_accessor :raw, :code, :message

    def self.parse(raw)
      new(raw).tap { |resp| resp.parse }
    end

    def initialize(raw)
      @raw = raw
    end

    def parse
      @code = @raw[PARSE_RE, 1].to_i
      @message = @raw[PARSE_RE, 2]
    end

    def needs_long_response?
      false
    end

    def to_s
      "#{self.class} code: #{code} message: #{message}"
    end
  end

  NNTPOKResponse = Class.new(NNTPResponse)

  QuitResponse = Class.new(NNTPOKResponse)
  GreetingResponse = Class.new(NNTPOKResponse)

  class GroupResponse < NNTPOKResponse
    PARSE_RE = /(\d*)\s*(\d*)\s(\d*)\s(\w.*)/i

    attr_reader :group, :num_articles, :low, :high

    def parse
      super
      @num_articles = message[PARSE_RE, 1].to_i
      @low          = message[PARSE_RE, 2].to_i
      @high         = message[PARSE_RE, 3].to_i
      @group        = message[PARSE_RE, 4]
    end
  end

  class ArticleResponse < NNTPOKResponse
    attr_accessor :data

    def needs_long_response?
      (200..299).include?(@code)
    end
  end

  class DateResponse < NNTPOKResponse
    attr_reader :date

    def parse
      super
      @date = DateTime.strptime(@message, '%Y%m%d%H%M%S')
    end
  end

  module StatResponseParser
    PARSE_RE = /(\d*)\s(.*)/i

    attr_reader :article_num, :message_id

    def parse
      super
      @article_num  = message[PARSE_RE, 1].to_i
      @message_id   = message[PARSE_RE, 2]
    end
  end

  class StatResponse < NNTPOKResponse
    include StatResponseParser
  end

  class NextResponse < NNTPOKResponse
    include StatResponseParser
  end

  class PrevResponse < NNTPOKResponse
    include StatResponseParser
  end
end
