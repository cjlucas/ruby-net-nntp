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
    411 => NNTPInvalidNewsgroupError,
    412 => NNTPNoNewsgroupSelectedError,
    420 => NNTPInvalidArticleNumberError,
    421 => NNTPNoArticleFoundError,
    422 => NNTPNoArticleFoundError,
    423 => NNTPNoArticleFoundError,
    430 => NNTPNoArticleFoundError,
  }
end
