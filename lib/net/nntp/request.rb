require_relative 'response'

module Net
  class NNTPRequest
    attr_accessor :raw

    def initialize(raw)
      @raw = raw
    end

    def resp_klass(code)
      NNTPOKResponse
    end
  end

  class NNTP

    #
    # DATE
    #

    class Date < NNTPRequest
      def initialize
        super('DATE')
      end

      def resp_klass(code)
        DateResponse
      end
    end

    #
    # GROUP
    #

    class Group < NNTPRequest
      def initialize(group)
        super("GROUP #{group}")
      end

      def resp_klass(code)
        code == 211 ? GroupResponse : Response
      end
    end

    #
    # ARTICLE
    #

    class Article < NNTPRequest
      def initialize(param)
        super("ARTICLE #{param}")
      end

      def resp_klass(code)
        ArticleResponse
      end
    end

    #
    # QUIT
    #

    class Quit < NNTPRequest
      def initialize
        super('QUIT')
      end

      def resp_klass(code)
        QuitResponse
      end
    end

    class Stat < NNTPRequest
      def initialize(param)
        super("STAT #{param}")
      end

      def resp_klass(code)
        StatResponse
      end
    end
  end
end
