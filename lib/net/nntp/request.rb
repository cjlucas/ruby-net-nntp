require_relative 'response'

module Net
  class NNTPRequest
    RESPONSES = ::Net::NNTP_RESPONSES
    attr_accessor :raw

    def initialize(*params)
      raw_a = []
      raw_a << self.class::METHOD
      params.each { |param| raw_a << param }
      @raw = raw_a.join(' ')
    end

    def response_class(code)
      klass = self.class

      # traverse the ancestor chain until we find a valid response
      while klass.constants.include?(:RESPONSES)
        klass::RESPONSES.each do |key, resp_klass|
          if key.is_a?(Fixnum)
            return resp_klass if key == code
          elsif key.is_a?(Range)
            return resp_klass if key.include?(code)
          end
        end

        klass = klass.superclass
      end

      raise Error, 'could not find a valid response'
    end
  end

  class NNTP
    class Date < NNTPRequest
      METHOD = 'DATE'
      RESPONSES = { 111 => NNTPDateResponse }
    end

    class Group < NNTPRequest
      METHOD = 'GROUP'
      RESPONSES = { 211 => NNTPGroupResponse }
    end

    class Article < NNTPRequest
      METHOD = 'ARTICLE'
      RESPONSES = { 220 => NNTPArticleResponse }
    end

    class Quit < NNTPRequest
      METHOD = 'QUIT'
      RESPONSES = { 205 => NNTPQuitResponse }
    end

    class Stat < NNTPRequest
      METHOD = 'STAT'
      RESPONSES = { 223 => NNTPStatResponse }
    end

    class Next < NNTPRequest
      METHOD = 'NEXT'
      RESPONSES = { 223 => NNTPNextResponse }
    end

    class Last < NNTPRequest
      METHOD = 'LAST'
      RESPONSES = { 223 => NNTPLastResponse }
    end

  end

end
