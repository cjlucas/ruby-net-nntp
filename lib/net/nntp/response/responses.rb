require_relative 'parsers'

module Net
  NNTPQuitResponse      = Class.new(NNTPOKResponse)
  NNTPGreetingResponse  = Class.new(NNTPOKResponse)

  class NNTPStatResponse < NNTPOKResponse
    include NNTPStatResponseParser
  end

  class NNTPNextResponse < NNTPOKResponse
    include NNTPStatResponseParser
  end

  class NNTPLastResponse < NNTPOKResponse
    include NNTPStatResponseParser
  end

  class NNTPDateResponse < NNTPOKResponse
    include NNTPDateResponseParser
  end

  class NNTPGroupResponse < NNTPOKResponse
    include NNTPGroupResponseParser
  end

  class NNTPListGroupResponse < NNTPLongResponse
    include NNTPGroupResponseParser

    # @return [Array<Integer>] an array of article numbers
    attr_reader :articles

    def handle_long_response(data)
      super(data)
      @articles = @raw_data.split("\r\n")
      @articles.collect! { |article| article.to_i }
    end
  end

  class NNTPHeadResponse < NNTPLongResponse
    include NNTPStatResponseParser
    include NNTPHeaderParser

    # @return [Hash] the parsed key-value headers
    attr_reader :headers

    def has_long_response?
      @code == 221
    end

    def handle_long_response(data)
      super(data)
      @headers = parse_headers(data)
    end
  end

  class NNTPBodyResponse < NNTPLongResponse
    include NNTPStatResponseParser
    include NNTPBodyParser

    # @return [String] the selected body
    attr_reader :body

    def has_long_response?
      @code == 222
    end

    def handle_long_response(data)
        super(data)
        @body = parse_body(data)
    end
  end

  class NNTPArticleResponse < NNTPLongResponse
    include NNTPStatResponseParser
    include NNTPHeaderParser

    # @return [NNTPArticle] the selected article
    attr_reader :article

    def has_long_response?
      @code == 220
    end

    def handle_long_response(data)
      super(data)
      @article = Net::NNTPArticle.parse(data)
    end
  end

  NNTPHelpResponse          = Class.new(NNTPLongResponse)
  NNTPCapabilitiesResponse  = Class.new(NNTPLongResponse)

  # 200
  NNTPPostingAllowed          = Class.new(NNTPOKResponse)
  # 201
  NNTPPostingProhibited       = Class.new(NNTPOKResponse)
  # 235, 240
  NNTPArticleReceived         = Class.new(NNTPOKResponse)
  # 281
  NNTPAuthenticationAccepted  = Class.new(NNTPOKResponse)
  # 324
  NNTPSendArticle             = Class.new(NNTPOKResponse)
  # 381
  NNTPPasswordRequired        = Class.new(NNTPOKResponse)

  # 400
  NNTPServiceTemporarilyUnavailableError  = Class.new(NNTPErrorResponse)
  # 411
  NNTPInvalidNewsgroupError               = Class.new(NNTPErrorResponse)
  # 412
  NNTPNoNewsgroupSelectedError            = Class.new(NNTPErrorResponse)
  # 420
  NNTPInvalidArticleNumberError           = Class.new(NNTPErrorResponse)
  # 421, 422, 423, 430
  NNTPNoArticleFoundError                 = Class.new(NNTPErrorResponse)
  # 435
  NNTPArticleNotWantedError               = Class.new(NNTPErrorResponse)
  # 436
  NNTPTransferFailedError                 = Class.new(NNTPErrorResponse)
  # 436
  NNTPTransferNotPossibleError            = Class.new(NNTPErrorResponse)
  # 437
  NNTPTransferRejectedError               = Class.new(NNTPErrorResponse)
  # 440
  NNTPPostingNotPermittedError            = Class.new(NNTPErrorResponse)
  # 441
  NNTPPostingFailedError                  = Class.new(NNTPErrorResponse)
  # 482 (RFC4643)
  NNTPCommandIssuedOutOfSequenceError     = Class.new(NNTPErrorResponse)
  # 483 (RFC4643)
  NNTPStrongerAuthenticationRequiredError = Class.new(NNTPErrorResponse)

  # 502
  NNTPServicePermenentlyUnavailableError  = Class.new(NNTPErrorResponse)
  # 502 (RFC4643)
  NNTPCommandUnavailableError             = Class.new(NNTPErrorResponse)

  NNTP_RESPONSES = {
    #(0..501) => NNTPResponse,
    215 => NNTPLongResponse,
    220 => NNTPLongResponse,
    221 => NNTPLongResponse,
    222 => NNTPLongResponse,
    224 => NNTPLongResponse,
    225 => NNTPLongResponse,
    230 => NNTPLongResponse,
    231 => NNTPLongResponse,
    281 => NNTPAuthenticationAccepted,
    381 => NNTPPasswordRequired,

    400 => NNTPServiceTemporarilyUnavailableError,
    411 => NNTPInvalidNewsgroupError,
    412 => NNTPNoNewsgroupSelectedError,
    420 => NNTPInvalidArticleNumberError,
    421 => NNTPNoArticleFoundError,
    422 => NNTPNoArticleFoundError,
    423 => NNTPNoArticleFoundError,
    430 => NNTPNoArticleFoundError,

    502 => NNTPServicePermenentlyUnavailableError,
  }
end
