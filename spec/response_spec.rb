require_relative 'spec_helper'

describe Net::NNTPResponse do
  it 'parses raw responses correctly' do
    cases = [
      {
        raw:      '200 Ok',
        code:     200,
        message:  'Ok',
      },
      {
        raw:      '200    Ok',
        code:     200,
        message:  'Ok',
      },

      {
        raw:      '200    Ok   ',
        code:     200,
        message:  'Ok   ',
      },
    ]

    cases.each do |c|
      resp = Net::NNTPResponse.parse(c[:raw])
      resp.code.should eq(c[:code])
      resp.message.should eql(c[:message])
    end
  end
end

describe Net::NNTPGroupResponse do
  it 'parses raw responses correctly' do
    resp = Net::NNTPGroupResponse.parse('211 70828 256246 327073 comp.lang.ruby')
    resp.code.should eq(211)
    resp.low.should eq(256246)
    resp.high.should eq(327073)
    resp.num_articles.should eq(70828)
    resp.group.should eql('comp.lang.ruby')
  end
end

describe Net::NNTPListGroupResponse do
  it 'parses raw responses correctly' do
    resp = Net::NNTPListGroupResponse.parse('211 70828 256246 327073 comp.lang.ruby')
    resp.code.should eq(211)
    resp.low.should eq(256246)
    resp.high.should eq(327073)
    resp.num_articles.should eq(70828)
    resp.group.should eql('comp.lang.ruby')
    expect(resp.has_long_response?).to be_true
  end

  it 'parses long response correctly' do
    resp = Net::NNTPListGroupResponse.parse('211 70828 256246 327073 comp.lang.ruby')
    long_response = "1\r\n" \
    + "2\r\n" \
    + "3\r\n" \
    + "4\r\n" \
    + "5\r\n" \
    + "6\r\n" \
    + "7\r\n" \
    + "8\r\n"

    resp.handle_long_response(long_response)
    resp.articles.size.should eq(8)
    resp.articles.should eql((1..8).to_a)
  end
end

describe Net::NNTPStatResponse do
  it 'parses raw responses correctly' do
    resp = Net::NNTPStatResponse.parse('223 256247 <eca9deb9-3adf-4015-a6f7-f7b0c730f7a6@f63g2000hsf.googlegroups.com>')
    resp.code.should eq(223)
    resp.article_num.should eq(256247)
    resp.message_id.should eql('<eca9deb9-3adf-4015-a6f7-f7b0c730f7a6@f63g2000hsf.googlegroups.com>')
  end
end

describe Net::NNTPDateResponse do
  it 'parses raw responses correctly' do
    resp = Net::NNTPDateResponse.parse('111 20140128175609')
    resp.date.year.should   eq(2014)
    resp.date.month.should  eq(1)
    resp.date.day.should    eq(28)
    resp.date.hour.should   eq(17)
    resp.date.minute.should eq(56)
    resp.date.second.should eq(9)
  end
end

describe Net::NNTPHeadResponse do
  it 'parses raw responses correctly' do
    resp = Net::NNTPHeadResponse.parse('221 256246 <6jmg6qF411jrU1@mid.individual.net>')
    resp.code.should eq(221)
    resp.article_num.should eq(256246)
    resp.message_id.should eql('<6jmg6qF411jrU1@mid.individual.net>')
  end

  it 'parses headers correctly' do
    headers = {
      'From'            => 'Chris Lucas <chris@notmyemail.com>',
      'Newsgroups'      => 'comp.lang.ruby',
      'Date'            => 'Tue, 28 May 2013 14:11:30 -0700 (PDT)',
      'User-Agent'      => 'G2/1.0',
      'Injection-Info'  => 'glegroupsg2000goo.googlegroups.com; posting-host=24.207.73.75; posting-account=TOgF7woAAAApoE80LVC0mIP5si3FWVbt'
    }
    raw_headers = ''
    headers.each_pair { |k, v| raw_headers << "#{k}: #{v}\r\n"}
    resp = Net::NNTPHeadResponse.parse('221')
    resp.handle_long_response(raw_headers)
    resp.headers.should eql(headers)
  end
end

describe Net::NNTPBodyResponse do
  it 'parses raw responses correctly' do
    resp = Net::NNTPBodyResponse.parse('222 0 <45223423@example.com>')
    resp.code.should eq(222)
    resp.article_num.should eq(0)
    resp.message_id.should eql('<45223423@example.com>')
    expect(resp.has_long_response?).to be_true

    body = "This is just a test article.\r\nWith multiple lines.\r\n"
    resp.handle_long_response(body)
    resp.body.should eql(body)
  end
end

describe Net::NNTPArticleResponse do
  it 'parses raw responses correctly' do
    resp = Net::NNTPArticleResponse.parse('220 0 <45223423@example.com>')
    resp.code.should eq(220)
    resp.article_num.should eq(0)
    resp.message_id.should eql('<45223423@example.com>')
    expect(resp.has_long_response?).to be_true

    article = "Path: pathost!demo!whitehouse!not-for-mail\r\n" \
    + "From: \"Demo User\" <nobody@example.net>\r\n" \
    + "Newsgroups: misc.test\r\n" \
    + "Subject: I am just a test article\r\n" \
    + "Date: 6 Oct 1998 04:38:40 -0500\r\n" \
    + "Organization: An Example Net, Uncertain, Texas\r\n" \
    + "Message-ID: <45223423@example.com>\r\n\r\n" \
    + "This is just a test article.\r\n" \
    + "With multiple lines.\r\n"

    expected_headers = {
      'Path' => 'pathost!demo!whitehouse!not-for-mail',
      'From' => '"Demo User" <nobody@example.net>',
      'Newsgroups' => 'misc.test',
      'Subject' => 'I am just a test article',
      'Date' => '6 Oct 1998 04:38:40 -0500',
      'Organization' => 'An Example Net, Uncertain, Texas',
      'Message-ID' => '<45223423@example.com>'
    }

    expected_body = "This is just a test article.\r\nWith multiple lines.\r\n"

    resp.handle_long_response(article)
    resp.headers.should eql(expected_headers)
    resp.body.should eql(expected_body)
  end
end