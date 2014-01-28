require 'socket'

require_relative 'nntp/request'
require_relative 'nntp/response'

module Net
  class NNTP
    def initialize(host, port, user, pass)
      @socket = TCPSocket.new(host, port)
      read_greeting
      login(user, pass)
    end

    def login(user, pass)
      puts request(NNTPRequest.new("AUTHINFO USER #{user.chomp}"))
      puts request(NNTPRequest.new("AUTHINFO PASS #{pass.chomp}"))
    end

    def request(req)
      # use a generic request if a valid request subclass is not specifed
      req = NNTPRequest.new(req.to_s) unless req.is_a?(NNTPRequest)

      puts ">>> #{req.raw}"
      @socket.write(req.raw << "\r\n")

      raw = read_short_response
      resp = NNTPResponse.parse(raw)
      puts "<<< #{resp.raw}"

      resp = req.resp_klass(resp.code).parse(raw)

      if resp.needs_long_response?
        resp.data = read_long_response
      end

      resp
    end

    def group(group)
      request Group.new(group.chomp)
    end

    def article(param)
      request Article.new(param.chomp)
    end

    def stat(param)
      request Stat.new(param.chomp)
    end

    def next
      request Next.new
    end

    def prev
      request Prev.new
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
        resp << buf
        break if resp[term_bytes_range].bytes == term_bytes
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
      GreetingResponse.new(read_short_response)
    end

  end
end
