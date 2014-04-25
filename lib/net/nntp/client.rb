module Net
  class NNTPClient
    # A block interface for a NNTP session.
    #
    # @param [host] host the hostname of the NNTP server
    # @param [port] port the port of the NNTP server
    #
    # @yield [nntp]
    # @yieldparam [NNTPClient]
    #
    # @return [void]
    #
    def self.start(host, port, &block)
      client = new
      client.connect(host, port)
      block.call(client) # TODO: wrap this in a begin/rescue/ensure block to ensure socket is closed
      client.close
    end

    # Connect to a NNTP session.
    #
    # @param [String] host the hostname of the NNTP server
    # @param [Integer] port the port of the NNTP server
    # @param [Boolean] use_ssl
    #
    # @return [NNTPGreetingResponse] the greeting sent upon connecting to the server
    #
    def connect(host, port, use_ssl = false)
      @socket = TCPSocket.new(host, port.to_i)
      if use_ssl
        @socket = OpenSSL::SSL::SSLSocket.new(@socket)
        @socket.sync_close
        @socket.connect
      end
      read_greeting
    end

    # Get the server's current capabilities
    #
    # @return [NNTPCapabilitiesResponse]
    #
    # @note they keyword argument is not used by RFC3977, but it is
    # listed as an optional parameter of CAPABILITIES.
    #
    def capabilities(keyword = nil)
      request Net::NNTP::Capabilities.new(keyword)
    end

    # Switch mode (for use on a mode-switching server)
    #
    # @return [NNTPResponse] Possible responses:
    #   {NNTPPostingAllowed},
    #   {NNTPPostingProhibited},
    #   {NNTPServicePermenentlyUnavailableError}
    #
    def mode_reader
      request Net::NNTP::ModeReader.new
    end

    # Send an AUTHINFO USER request.
    #
    # @param [String] username the username to send
    #
    # @return [NNTPResponse] Possible responses:
    #   {NNTPAuthenticationAccepted},
    #   {NNTPPasswordRequired},
    #   {NNTPStrongerAuthenticationRequiredError},
    #   {NNTPCommandUnavailableError}
    #
    def authinfo_user(username)
      request Net::NNTP::AuthInfoUser.new(username)
    end

    # Send an AUTHINFO PASS request.
    #
    # @param [String] password the password to send
    #
    # @return [NNTPResponse] Possible responses:
    #   {NNTPAuthenticationAccepted},
    #   {NNTPCommandIssuedOutOfSequenceError},
    #   {NNTPCommandUnavailableError}
    #
    def authinfo_pass(password)
      request Net::NNTP::AuthInfoPass.new(password)
    end

    # Get the current time.
    #
    # @return [NNTPDateResponse]
    #
    def date
      request Net::NNTP::Date.new
    end

    # Select a group.
    #
    # @param [String] group the group to be selected
    #
    # @return [NNTPResponse] Possible responses:
    #   {NNTPGroupResponse}, {NNTPInvalidNewsgroupError}
    #
    def group(group)
      request Net::NNTP::Group.new(group)
    end

    # List the articles of a group
    #
    # @param [String] group the group to be selected.
    #   If nil, the currently selected group is used.
    # @param [Range] range the range of articles to select.
    #   If nil, all articles are selected.
    #
    # @return [NNTPResponse] Possible responses:
    #   {NNTPListGroupResponse},
    #   {NNTPInvalidNewsgroupError},
    #   {NNTPNoNewsgroupSelectedError}
    #
    # @note range is a newer NNTP feature and may not be supported
    #
    def list_group(group = nil, range = nil)
      request Net::NNTP::ListGroup.new(group, range)
    end

    # Get the head of an article.
    #
    # @param [Object] param Can be either the article number of the
    #   currently selected group, or a message-id. If nil, the latest
    #   article is chosen.
    #
    # @return [NNTPResponse] Possible resposnes:
    #   {NNTPHeadResponse},
    #   {NNTPNoNewsgroupSelectedError},
    #   {NNTPInvalidArticleNumberError},
    #   {NNTPNoArticleFoundError}
    #
    def head(param = nil)
      request Net::NNTP::Head.new(param)
    end

    # Get the body of an article.
    #
    # @param [Object] param Can be either the article number of the
    #   currently selected group, or a message-id. If nil, the latest
    #   article is chosen.
    #
    # @return [NNTPResponse] Possible resposnes:
    #   {NNTPBodyResponse},
    #   {NNTPNoNewsgroupSelectedError},
    #   {NNTPInvalidArticleNumberError},
    #   {NNTPNoArticleFoundError}
    #
    def body(param = nil)
      request Net::NNTP::Body.new(param)
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
      request Net::NNTP::Article.new(param)
    end

    # Get the stat line for an article.
    #
    # @param [Object] param Can be either the article number of the
    #   currently selected group, or a message-id. If nil, the latest
    #   article is chosen.
    #
    # @return [NNTPResponse] Possible responses:
    #   {NNTPStatResponse},
    #   {NNTPNoNewsgroupSelectedError},
    #   {NNTPInvalidArticleNumberError},
    #   {NNTPNoArticleFoundError}
    #
    def stat(param = nil)
      request Net::NNTP::Stat.new(param)
    end

    # Get the stat line for the next article.
    #
    # @return [NNTPResponse] Possible responses:
    #   {NNTPNextResponse},
    #   {NNTPNoNewsgroupSelectedError},
    #   {NNTPInvalidArticleNumberError},
    #   {NNTPNoArticleFoundError}
    #
    def next
      request Net::NNTP::Next.new
    end

    # Get the stat line for the last article.
    #
    # @return [NNTPResponse] Possible responses:
    #   {NNTPLastResponse},
    #   {NNTPNoNewsgroupSelectedError},
    #   {NNTPInvalidArticleNumberError},
    #   {NNTPNoArticleFoundError}
    #
    def last
      request Net::NNTP::Last.new
    end

    # Get the server's help info.
    #
    # @return [NNTPHelpResponse]
    #
    def help
      request Net::NNTP::Help.new
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
      resp = request Net::NNTP::Post.new
      return resp if resp.is_a?(Net::NNTPErrorResponse)

      if block_given?
        article = NNTPArticle.new
        block.call(resp, article)
      end

      write_long(article.to_s)
      read_response(Net::NNTP::Post.new)
    end

    # Notify the server that an article is available to be sent.
    #
    # This method can be used in one of two ways. Either by supplying
    # the article via the method parameter, or by using the block interface.
    # The block interface is intended to be used if the first first stage
    # IHAVE response is needed. Also note that if the first IHAVE response
    # is a {NNTPErrorResponse}, the block will not be executed and the first
    # response will be returned.
    #
    # @param [String] message_id the message-id of the article
    # @param [NNTPArticle] article the article to be posted
    #
    # @yield [response, article] the (optional block interface)
    # @yieldparam [NNTPOKResponse] response the first stage response
    # @yieldparam [NNTPArticle] article the article to be posted
    #
    # @return [NNTPResponse] Possible responses:
    #   {NNTPArticleReceived},
    #   {NNTPArticleNotWantedError},
    #   {NNTPTransferNotPossibleError},
    #   {NNTPTransferFailedError},
    #   {NNTPTransferRejectedError}
    #
    def ihave(message_id, article = nil, &block)
      resp = request Net::NNTP::IHaveFirstStage.new(message_id)
      return resp if resp.is_a?(Net::NNTPErrorResponse)

      if block_given?
        article = NNTPArticle.new
        block.call(resp, article)
      end

      write_long(article)
      read_response(Net::NNTP::IHaveSecondStage.new)
    end

    # Close the connection.
    #
    # @return [NNTPQuitResponse]
    #
    # @note Any subsequent requests will result in a raised Exception.
    #
    def quit
      request Net::NNTP::Quit.new
    end

    private

    def request(req)
      # use a generic request if a valid request subclass is not specifed
      req = NNTPGenericRequest.new(req.to_s) unless req.is_a?(NNTPRequest)

      write_short(req.raw)
      read_response(req)
    end

    def close
      @socket.close
    end

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
