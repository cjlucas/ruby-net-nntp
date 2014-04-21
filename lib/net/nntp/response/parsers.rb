require 'date'

module Net
  module NNTPStatResponseParser
    PARSE_RE = /(\d*)\s(.*)/i

    # @return [Integer] the number of the article within the group
    attr_reader :article_num
    # @return [String] the message id for the article
    attr_reader :message_id

    def parse
      super
      @article_num  = message[PARSE_RE, 1].to_i
      @message_id   = message[PARSE_RE, 2]
    end
  end

  module NNTPDateResponseParser
    # @return [DateTime] the current server time
    attr_reader :date

    def parse
      super
      @date = DateTime.strptime(@message, '%Y%m%d%H%M%S')
    end
  end

  module NNTPGroupResponseParser
    PARSE_RE = /(\d*)\s*(\d*)\s(\d*)\s(\w.*)/i

    # @return [String] the name of the newsgroup
    attr_reader :group
    # @return [Integer] the number of articles in the group
    attr_reader :num_articles
    # @return [Integer] the low water mark
    attr_reader :low
    # @return [Integer] the high water mark
    attr_reader :high

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

  module NNTPBodyParser
    def parse_body(raw_body)
      body = ''
      raw_body.each_line do |line|
        range = line[0] == '.' ? 1..-1 : 0..-1
        body << line[range]
      end

      body.chomp! # chomp trailing \r\n
    end
  end
end
