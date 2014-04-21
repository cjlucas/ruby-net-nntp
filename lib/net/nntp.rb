require 'socket'

require_relative 'nntp/article'
require_relative 'nntp/request'
require_relative 'nntp/response'

module Net
  class NNTP
    def initialize(host, port, user, pass)
      @socket = TCPSocket.new(host, port)
      read_greeting
      login(user, pass) unless [user, pass].include?(nil)
    end

    def login(user, pass)
      request "AUTHINFO USER #{user.chomp}"
      request "AUTHINFO PASS #{pass.chomp}"
    end

    def request(req)
      # use a generic request if a valid request subclass is not specifed
      req = NNTPGenericRequest.new(req.to_s) unless req.is_a?(NNTPRequest)

      write_short(req.raw)
      read_response(req)
    end

    def date
      request Date.new
    end

    def group(group)
      request Group.new(group)
    end

    # @note range is a newer nntp feature and may not be supported
    def list_group(group = nil, range = nil)
      request ListGroup.new(group, range)
    end

    def head(param = nil)
      request Head.new(param)
    end

    def body(param = nil)
      request Body.new(param)
    end

    # Select an article
    #
    # @note If param is nil, the current article will be selected
    # @param param the article number or message id
    #
    # @return [NNTPResponse] Possible responses:
    #   {NNTPArticleResponse},
    #   {NNTPNoNewsgroupSelectedError},
    #   {NNTPInvalidArticleNumberError},
    #   {NNTPNoArticleFoundError}
    #
    def article(param = nil)
      request Article.new(param)
    end

    def stat(param = nil)
      request Stat.new(param)
    end

    def next
      request Next.new
    end

    def last
      request Last.new
    end

    def help
      request Help.new
    end

    # Post an article.
    #
    # This method can be used in one of two ways, by directly supplying
    # and article to be posted via the method parameter, or by using the
    # block interface. The block interface is intented to be used
    # if the user has interest in the first stage POST response. Also note
    # that if the first POST response is a {NNTPErrorResponse}, the block
    # will not be executed and the first response will be returned.
    #
    # @param [NNTPArticle] article the article to be posted
    #
    # @yield [response, article] the (optional) block interface
    # @yieldparam [NNTPOKResponse] response the first stage response
    # @yieldparam [NNTPArticle] article the article to be posted
    #
    # @return [NNTPResponse] Possible responses:
    #   {NNTPPostingNotPermittedError},
    #   {NNTPArticleReceived},
    #   {NNTPPostingFailedError}
    #
    def post(article = nil, &block)
      resp = request Post.new
      return resp if resp.is_a?(Net::NNTPErrorResponse)

      if block_given?
        article = NNTPArticle.new
        block.call(resp, article)
      end

      write_long(article.to_s)
      read_response(Post.new)
    end

    def quit
      request Quit.new
    end

    def close
      @socket.close
    end

    private

    def read_raw_response(term_bytes)
      term_bytes_range = (-term_bytes.size..-1)

      resp = ''
      loop do
        buf = @socket.readline
        #puts buf
        resp << buf

        # workaround for Ruby 1.9
        bytes = []
        resp[term_bytes_range].each_byte { |byte| bytes << byte }
        break if bytes == term_bytes
      end

      resp
    end

    def write_short(data)
      puts ">>> #{data}"
      @socket.write(data << "\r\n")
    end

    def write_long(data)
      @socket.write(data << ".\r\n")
    end

    def read_response(req)
      raw = read_short_response
      resp = NNTPResponse.parse(raw)
      puts "<<< #{resp.raw}"

      resp = req.response_class(resp.code).parse(raw)

      if resp.has_long_response?
        resp.handle_long_response(read_long_response)
      end

      resp
    end

    def read_short_response
      read_raw_response([0x0d, 0x0a])
    end

    def read_long_response
      # trailing 2E 0D 0A should be stripped from response
      read_raw_response([0x0d, 0x0a, 0x2e, 0x0d, 0x0a])[0...-3]
    end

    def read_greeting
      NNTPGreetingResponse.new(read_short_response)
    end
  end
end
