require_relative 'response'

module Net
  class NNTPRequest
    RESPONSES = NNTP_RESPONSES
    attr_accessor :raw

    def initialize(*params)
      raw_a = []
      raw_a << self.class::METHOD
      params.each { |param| raw_a << param }
      @raw = raw_a.join(' ')
    end

    def response_class(code)
      self.class::RESPONSES.each do |key, resp_klass|
        if key.is_a?(Fixnum)
          return resp_klass if key == code
        elsif key.is_a?(Range)
          return resp_klass if key.include?(code)
        end
      end

      # TODO: check if superclass has RESPONSES constant first
      super(code)
    end
  end

  class NNTP
    class Date < NNTPRequest
      METHOD = 'DATE'
    end

    class Group < NNTPRequest
      METHOD = 'GROUP'
      RESPONSES = { 211 => NNTPGroupResponse }
    end

    class Article < NNTPRequest
      METHOD = 'ARTICLE'
    end

    class Quit < NNTPRequest
      METHOD = 'QUIT'
    end

    class Stat < NNTPRequest
      METHOD = 'STAT'
    end

    class Next < NNTPRequest
      METHOD = 'NEXT'
      RESPONSES = { 223 => NNTPNextResponse }
    end

    class Prev < NNTPRequest
      METHOD = 'PREV'
    end
  end

  NNTP_RESPONSES = {
    (0..501) => NNTPResponse,
  }
end
