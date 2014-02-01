require 'net/nntp/response/parsers'

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

  class NNTPArticleResponse < NNTPLongResponse
    attr_accessor :data

    def needs_long_response?
      (200..299).include?(@code)
    end

    def handle_long_response(data)
      @data = data
    end
  end

  # 412
  NoNewsgroupSelectedError = Class.new(NNTPErrorResponse)
  # 420
  InvalidArticleNumberError = Class.new(NNTPErrorResponse)
  # 421, 422, 423, 430
  NoArticleFoundError = Class.new(NNTPErrorResponse)



  NNTP_RESPONSES = {
    #(0..501) => NNTPResponse,
    412 => NoNewsgroupSelectedError,
    420 => InvalidArticleNumberError,
    421 => NoArticleFoundError,
    422 => NoArticleFoundError,
    423 => NoArticleFoundError,
    430 => NoArticleFoundError,
  }
end
