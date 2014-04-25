require_relative 'spec_helper'

def mock_server_and_connect(client, *responses)
  fake_socket = double('socket')
  fake_socket.stub(:readline).and_return(*responses)
  fake_socket.stub(:write).and_return(nil)

  TCPSocket.stub(:new).and_return(fake_socket)
  client.connect(nil, nil)
end

describe Net::NNTPClient do
  before(:each) do
    @client = Net::NNTPClient.new
  end

  after(:all) do
    TCPSocket.unstub(:new)
  end

  describe '#date' do
    it 'should return the correct response class' do
      mock_server_and_connect(@client, "111 20140425164350\r\n")
      @client.date.class.should eq(Net::NNTPDateResponse)
    end
  end

  describe '#help' do
    it 'should return the correct response class' do
      mock_server_and_connect(@client,
        "100 Legal commands\r\n  authinfo user Name|pass Password|generic <prog> <args>\r\n.\r\n")
      @client.help.class.should eq(Net::NNTPHelpResponse)
    end
  end

  describe '#authinfo_user' do
    it 'should return the correct response class' do
      mock_server_and_connect(@client, "381 PASS required\r\n")
      @client.authinfo_user(nil).class.should eq(Net::NNTPPasswordRequired)
    end
  end

  describe '#authinfo_user' do
    it 'should return the correct response class' do
      mock_server_and_connect(@client, "381 PASS required\r\n")
      @client.authinfo_user(nil).class.should eq(Net::NNTPPasswordRequired)
    end
  end

  describe '#authinfo_pass' do
    it 'should return the correct response class' do
      mock_server_and_connect(@client, "502 Authentication error\r\n")
      @client.authinfo_pass(nil).should be_a_kind_of(Net::NNTPErrorResponse)
    end
  end

  describe '#group' do
    it 'should return the correct response class' do
      mock_server_and_connect(@client, "211 120 72 217 comp.lang.ruby\r\n")
      @client.group('comp.lang.ruby').class.should eq(Net::NNTPGroupResponse)
    end
  end

  describe '#list_group' do
    it 'should return the correct response class' do
      mock_server_and_connect(@client,
        "211 120 72 217 comp.lang.ruby\r\n72\r\n76\r\n77\r\n78\r\n.\r\n")
      @client.list_group('comp.lang.ruby').class.should eq(Net::NNTPListGroupResponse)
    end
  end

  describe '#head' do
    it 'should return the correct response class' do
      mock_server_and_connect(@client,
        "221 72 <87fvx0bqyz.fsf@xts.gnuu.de> head\r\nNewsgroups: comp.lang.ruby\r\n.\r\n")
      @client.head(nil).class.should eq(Net::NNTPHeadResponse)
    end
  end

  describe '#body' do
    it 'should return the correct response class' do
      mock_server_and_connect(@client,
        "222 72 <87fvx0bqyz.fsf@xts.gnuu.de> body\r\n body goes here\r\n.\r\n")
      @client.body(nil).class.should eq(Net::NNTPBodyResponse)
    end
  end

  describe '#article' do
    it 'should return the correct response class' do
      mock_server_and_connect(@client,
        "220 72 <87fvx0bqyz.fsf@xts.gnuu.de> article\r\nPath: Whatever\r\n\r\nsome article here\r\n.\r\n")
      @client.article(nil).class.should eq(Net::NNTPArticleResponse)
    end
  end

  describe '#stat' do
    it 'should return the correct response class' do
      mock_server_and_connect(@client,
        "223 72 <87fvx0bqyz.fsf@xts.gnuu.de> status\r\n")
      @client.stat(nil).class.should eq(Net::NNTPStatResponse)
    end
  end

  describe '#next' do
    it 'should return the correct response class' do
      mock_server_and_connect(@client,
        "223 76 <ctquq817hpin9jd5f0uhr17dihcscmkdlo@4ax.com> Article retrieved; request text separately.\r\n")
      @client.next.class.should eq(Net::NNTPNextResponse)
    end
  end

  describe '#last' do
    it 'should return the correct response class' do
      mock_server_and_connect(@client,
        "223 72 <87fvx0bqyz.fsf@xts.gnuu.de> Article retrieved; request text separately.\r\n")
      @client.last.class.should eq(Net::NNTPLastResponse)
    end
  end

  describe '#quit' do
    it 'should return the correct response class' do
      mock_server_and_connect(@client, "205 .\r\n")
      @client.quit.class.should eq(Net::NNTPQuitResponse)
    end
  end
end