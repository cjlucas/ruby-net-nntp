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

  class NNTPPrevResponse < NNTPOKResponse
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

  NNTP_RESPONSES = {
    (0..501) => NNTPResponse,
  }
end
