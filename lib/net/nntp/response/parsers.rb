require 'date'

module Net
  module NNTPStatResponseParser
    PARSE_RE = /(\d*)\s(.*)/i
    attr_reader :article_num, :message_id

    def parse
      super
      @article_num  = message[PARSE_RE, 1].to_i
      @message_id   = message[PARSE_RE, 2]
    end
  end

  module NNTPDateResponseParser
    attr_reader :date

    def parse
      super
      @date = DateTime.strptime(@message, '%Y%m%d%H%M%S')
    end
  end

  module NNTPGroupResponseParser
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

  module NNTPHeaderParser
    HEADER_PARSE_RE = /(.*):\s(.*)/i

    def parse_headers(raw_headers)
      headers = {}
      raw_headers.to_s.each_line do |line|
        line.chomp!
        k = line[HEADER_PARSE_RE, 1]
        v = line[HEADER_PARSE_RE, 2]
        headers[k] = v
      end

      headers
    end
  end
end
