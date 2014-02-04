require_relative 'response'

module Net
  class NNTPGenericRequest
    RESPONSES = ::Net::NNTP_RESPONSES
    attr_reader :raw

    def initialize(raw)
      @raw = raw
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

      raise Exception, 'could not find a valid response'
    end
  end

  class NNTPRequest < NNTPGenericRequest
    def initialize(*params)
      super("#{self.class::METHOD} #{process_parameters(params)}")
    end

    def process_parameters(params)
      processed = []
      params.each do |param|
        val = case
              when param.is_a?(String)
                param
              when param.is_a?(Range)
                "#{param.first}-#{param.last}"
              end

        processed << val
      end

      processed.join(' ')
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

    class ListGroup < NNTPRequest
      METHOD = 'LISTGROUP'
      RESPONSES = { 211 => NNTPListGroupResponse }
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

    class Help < NNTPRequest
      METHOD = 'HELP'
      RESPONSES = { 100 => NNTPHelpResponse }
    end
  end

end
