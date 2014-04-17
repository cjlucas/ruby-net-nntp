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
    attr_reader :body

    def has_long_response?
      @code == 222
    end

    def handle_long_response(data)
        super(data)
        @body = data
    end
  end

  class NNTPArticleResponse < NNTPLongResponse
    include NNTPStatResponseParser
    include NNTPHeaderParser
    attr_reader :headers, :body

    def has_long_response?
      @code == 220
    end

    def handle_long_response(data)
      super(data)
      split = data.index("\r\n\r\n")
      @headers = parse_headers(data[(0..split+1)])
      @body = data[(split+4..-1)]
    end
  end

  NNTPHelpResponse = Class.new(NNTPLongResponse)

  # 281
  NNTPAuthenticationAccepted = Class.new(NNTPOKResponse)
  # 381
  NNTPPasswordRequired = Class.new(NNTPOKResponse)

  # 411
  NNTPInvalidNewsgroupError = Class.new(NNTPErrorResponse)
  # 412
  NNTPNoNewsgroupSelectedError = Class.new(NNTPErrorResponse)
  # 420
  NNTPInvalidArticleNumberError = Class.new(NNTPErrorResponse)
  # 421, 422, 423, 430
  NNTPNoArticleFoundError = Class.new(NNTPErrorResponse)



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

    411 => NNTPInvalidNewsgroupError,
    412 => NNTPNoNewsgroupSelectedError,
    420 => NNTPInvalidArticleNumberError,
    421 => NNTPNoArticleFoundError,
    422 => NNTPNoArticleFoundError,
    423 => NNTPNoArticleFoundError,
    430 => NNTPNoArticleFoundError,
  }
end
