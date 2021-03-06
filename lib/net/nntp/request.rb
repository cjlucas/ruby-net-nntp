require_relative 'response'

module Net
  class NNTPGenericRequest
    RESPONSES = ::Net::NNTP_RESPONSES

    # @return [String] the raw request
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
      raw = self.class::METHOD.dup
      processed_params = process_parameters(params)
      raw << " #{processed_params}" unless processed_params.empty?
      super(raw)
    end

    def process_parameters(params)
      processed = []
      params.each do |param|
        next if param.nil?

        processed << case
                     when param.is_a?(Range)
                       process_range(param)
                     else
                       param.to_s
                     end
      end

      processed.join(' ')
    end

    private

    def process_range(range)
      range = range.begin..range.end-1 if range.exclude_end?
      range.end == -1 ? "#{range.begin}-" : "#{range.begin}-#{range.end}"
    end
  end


  module NNTP
    class AuthInfoUser < NNTPRequest
      METHOD = 'AUTHINFO USER'
      RESPONSES = {
        281 => NNTPAuthenticationAccepted,
        381 => NNTPPasswordRequired,
        483 => NNTPStrongerAuthenticationRequiredError,
        502 => NNTPCommandUnavailableError,
      }
    end

    class AuthInfoPass < NNTPRequest
      METHOD = 'AUTHINFO PASS'
      RESPONSES = {
        281 => NNTPAuthenticationAccepted,
        482 => NNTPCommandIssuedOutOfSequenceError,
        502 => NNTPCommandUnavailableError,
      }
    end

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

    class Head < NNTPRequest
      METHOD = 'HEAD'
      RESPONSES = { 221 => NNTPHeadResponse }
    end

    class Body < NNTPRequest
      METHOD = 'BODY'
      RESPONSES = { 222 => NNTPBodyResponse }
    end

    class Post < NNTPRequest
      METHOD = 'POST'
      RESPONSES = {
        # first stage
        340 => NNTPSendArticle,
        440 => NNTPPostingNotPermittedError,
        # second stage
        240 => NNTPArticleReceived,
        441 => NNTPPostingFailedError
      }
    end

    class IHaveFirstStage < NNTPRequest
      METHOD = 'IHAVE'
      RESPONSES = {
        335 => NNTPSendArticle,
        435 => NNTPArticleNotWantedError,
        436 => NNTPTransferNotPossibleError,
      }
    end

    class IHaveSecondStage < NNTPRequest
      METHOD = 'IHAVE'
      RESPONSES = {
        235 => NNTPArticleReceived,
        436 => NNTPTransferFailedError,
        437 => NNTPTransferRejectedError
      }
    end

    class Help < NNTPRequest
      METHOD = 'HELP'
      RESPONSES = { 100 => NNTPHelpResponse }
    end

    class Capabilities < NNTPRequest
      METHOD = 'CAPABILITIES'
      RESPONSES = { 101 => NNTPCapabilitiesResponse }
    end

    class ModeReader < NNTPRequest
      METHOD = 'MODE READER'
      RESPONSES = {
        200 => NNTPPostingAllowed,
        201 => NNTPPostingProhibited,
      }
    end
  end
end
