require_relative 'response/parsers'

module Net
  class NNTPArticle
    extend NNTPHeaderParser
    extend NNTPBodyParser

    # @return [Hash] the parsed key-value article headers
    attr_accessor :headers
    # @return [String] the parsed article body
    attr_accessor :body

    def self.parse(raw_article)
      split = raw_article.index("\r\n\r\n")

      new.tap do |article|
        article.headers = parse_headers(raw_article[(0..split+1)])
        article.body    = parse_body(raw_article)[(split+4..-1)]
      end
    end

    def initialize
      @headers = {}
    end

    def add_header(key, value)
      headers[key] = value
    end

    def to_s
      raw = ''
      headers.each_pair { |k, v| raw << "#{k}: #{v}\r\n"}
      raw << "\r\n"

      body.each_line do |line|
        orig_line = line
        line = line.chomp

        raw << '.' if line[0] == '.' # dot stuffing
        raw << line
        # don't add a newline if there wasn't one originally
        raw << "\r\n" unless line.eql?(orig_line)
      end

      raw << "\r\n"
    end
  end
end