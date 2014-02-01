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
      RESPONSES = { 111 => NNTPDateResponse }
    end

    class Group < NNTPRequest
      METHOD = 'GROUP'
      RESPONSES = { 211 => NNTPGroupResponse }
    end

    class Article < NNTPRequest
      METHOD = 'ARTICLE'
      RESPONSES = {
        220 => NNTPArticleResponse,
        #412 no newsgroup selected
        #420 article number invalid
        #423 no article with that number
        #430 (no article with that message id)
      }
    end

    class Quit < NNTPRequest
      METHOD = 'QUIT'
      RESPONSES = { 205 => NNTPQuitResponse }
    end

    class Stat < NNTPRequest
      METHOD = 'STAT'
      RESPONSES = {
        223 => NNTPStatResponse,
        #412 no newsgroup selected
        #420 current article number is invalid
        #423 no article with that number
        #430 (no article with that message id)
      }
    end

    class Next < NNTPRequest
      METHOD = 'NEXT'
      RESPONSES = {
        223 => NNTPNextResponse,
        #412 no newsgroup selected
        #420 current article number is invalid
        #421 no next article in this group
      }
    end

    # TODO: change me to Last
    class Prev < NNTPRequest
      METHOD = 'PREV'
      RESPONSES = {
        223 => NNTPPrevResponse,
        #412 no newsgroup selected
        #420 current article number is invalid
        #422 no previous article in this group
      }
    end

  end

end
