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
    req.response_class(411).should eq(Net::NNTPInvalidNewsgroupError)
  end
end

describe Net::NNTP::Article do
  it "returns the correct response class" do
    req = Net::NNTP::Article.new
    req.response_class(220).should eq(Net::NNTPArticleResponse)
    req.response_class(412).should eq(Net::NNTPNoNewsgroupSelectedError)
    req.response_class(420).should eq(Net::NNTPInvalidArticleNumberError)
    req.response_class(423).should eq(Net::NNTPNoArticleFoundError)
    req.response_class(430).should eq(Net::NNTPNoArticleFoundError)
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
    req.response_class(412).should eq(Net::NNTPNoNewsgroupSelectedError)
    req.response_class(420).should eq(Net::NNTPInvalidArticleNumberError)
    req.response_class(423).should eq(Net::NNTPNoArticleFoundError)
    req.response_class(430).should eq(Net::NNTPNoArticleFoundError)
  end
end

describe Net::NNTP::Last do
  it "returns the correct response class" do
    req = Net::NNTP::Last.new
    req.response_class(223).should eq(Net::NNTPLastResponse)
    req.response_class(412).should eq(Net::NNTPNoNewsgroupSelectedError)
    req.response_class(420).should eq(Net::NNTPInvalidArticleNumberError)
    req.response_class(422).should eq(Net::NNTPNoArticleFoundError)
    req.response_class(423).should eq(Net::NNTPNoArticleFoundError)
  end
end

describe Net::NNTP::Next do
  it "returns the correct response class" do
    req = Net::NNTP::Next.new
    req.response_class(223).should eq(Net::NNTPNextResponse)
    req.response_class(412).should eq(Net::NNTPNoNewsgroupSelectedError)
    req.response_class(420).should eq(Net::NNTPInvalidArticleNumberError)
    req.response_class(421).should eq(Net::NNTPNoArticleFoundError)
    req.response_class(423).should eq(Net::NNTPNoArticleFoundError)
  end
end
