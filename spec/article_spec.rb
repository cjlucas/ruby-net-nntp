require_relative 'spec_helper'

def raw_stock_headers
  "Path: pathost!demo!whitehouse!not-for-mail\r\n" \
  + "From: \"Demo User\" <nobody@example.net>\r\n" \
  + "Newsgroups: misc.test\r\n" \
  + "Subject: I am just a test article\r\n" \
  + "Date: 6 Oct 1998 04:38:40 -0500\r\n" \
  + "Organization: An Example Net, Uncertain, Texas\r\n" \
  + "Message-ID: <45223423@example.com>\r\n"
end

def parsed_stock_headers
    {
      'Path'          => 'pathost!demo!whitehouse!not-for-mail',
      'From'          => '"Demo User" <nobody@example.net>',
      'Newsgroups'    => 'misc.test',
      'Subject'       => 'I am just a test article',
      'Date'          => '6 Oct 1998 04:38:40 -0500',
      'Organization'  => 'An Example Net, Uncertain, Texas',
      'Message-ID'    => '<45223423@example.com>'
    }
end

def raw_article_with_body(body)
  raw_stock_headers + "\r\n" + body + "\r\n"
end

def new_article
  Net::NNTPArticle.new.tap { |article| article.headers = parsed_stock_headers }
end

describe Net::NNTPArticle do
  it 'parses a simple raw nntp article' do
    raw_body = "\r\n\r\nThis is just a test article.\r\n" \
    + "With multiple lines\r\n"
    expected_body = raw_body

    article = Net::NNTPArticle.parse(raw_article_with_body(raw_body))

    article.headers.should eql(parsed_stock_headers)
    article.body.should eql(expected_body)
  end

  it 'parses a raw nntp article with dot-stuffing' do
    raw_body = "WAIT FOR IT...\r\n...\r\n..\r\nBOOM."
    expected_body = "WAIT FOR IT...\r\n..\r\n.\r\nBOOM."

    article = Net::NNTPArticle.parse(raw_article_with_body(raw_body))
    article.headers.should eql(parsed_stock_headers)
    article.body.should eql(expected_body)
  end

  it 'generates a raw nntp article (no trailing newline)' do
    article = new_article
    article.body = 'What a boring body.'

    article.to_s.should eql(raw_article_with_body(article.body))
  end

  it 'generates a raw nntp article (needs dot-stuffing)' do
    article = new_article
    article.body = "WAIT FOR IT...\r\n..\r\n.\r\nBOOM."
    generated_body = "WAIT FOR IT...\r\n...\r\n..\r\nBOOM."

    article.to_s.should eql(raw_article_with_body(generated_body))
  end

  it 'generates a raw nntp article (convert unix newline to CRLF)' do
    article = new_article
    article.body = "Some body\nwith\nunix\n\nnewlines\n\n"
    generated_body = "Some body\r\nwith\r\nunix\r\n\r\nnewlines\r\n\r\n"

    article.to_s.should eql(raw_article_with_body(generated_body))
  end
end