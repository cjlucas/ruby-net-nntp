require_relative 'spec_helper'

describe Net::NNTP::Date do
  it "returns the correct response class" do
    req = Net::NNTP::Date.new
    req.response_class(111).should eq(Net::NNTPDateResponse)
  end
end

describe Net::NNTP::Group do
  it "returns the correct response class" do
    req = Net::NNTP::Group.new
    req.response_class(211).should eq(Net::NNTPGroupResponse)
  end
end

describe Net::NNTP::Article do
  it "returns the correct response class" do
    req = Net::NNTP::Article.new
    req.response_class(220).should eq(Net::NNTPArticleResponse)
  end
end

describe Net::NNTP::Quit do
  it "returns the correct response class" do
    req = Net::NNTP::Quit.new
    req.response_class(205).should eq(Net::NNTPQuitResponse)
  end
end

describe Net::NNTP::Stat do
  it "returns the correct response class" do
    req = Net::NNTP::Stat.new
    req.response_class(223).should eq(Net::NNTPStatResponse)
  end
end

describe Net::NNTP::Prev do
  it "returns the correct response class" do
    req = Net::NNTP::Prev.new
    req.response_class(223).should eq(Net::NNTPPrevResponse)
  end
end

describe Net::NNTP::Next do
  it "returns the correct response class" do
    req = Net::NNTP::Next.new
    req.response_class(223).should eq(Net::NNTPNextResponse)
  end
end
