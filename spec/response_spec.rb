require_relative 'spec_helper'

describe Net::NNTPResponse do
  it "parses raw responses correctly" do
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

describe Net::GroupResponse do
  it "parses raw responses correctly" do
    resp = Net::GroupResponse.parse('211 70828 256246 327073 comp.lang.ruby')
    resp.code.should eq(211)
    resp.low.should eq(256246)
    resp.high.should eq(327073)
    resp.num_articles.should eq(70828)
    resp.group.should eql('comp.lang.ruby')
  end
end

describe Net::StatResponse do
  it "parses raw responses correctly" do
    resp = Net::StatResponse.parse('223 256247 <eca9deb9-3adf-4015-a6f7-f7b0c730f7a6@f63g2000hsf.googlegroups.com>')
    resp.code.should eq(223)
    resp.article_num.should eq(256247)
    resp.message_id.should eql('<eca9deb9-3adf-4015-a6f7-f7b0c730f7a6@f63g2000hsf.googlegroups.com>')
  end
end

describe Net::DateResponse do
  it "parses raw responses correctly" do
    resp = Net::DateResponse.parse('111 20140128175609')
    resp.date.year.should   eq(2014)
    resp.date.month.should  eq(1)
    resp.date.day.should    eq(28)
    resp.date.hour.should   eq(17)
    resp.date.minute.should eq(56)
    resp.date.second.should eq(9)
  end
end
