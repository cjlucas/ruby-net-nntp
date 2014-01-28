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
    ]

    cases.each do |c|
      resp = Net::NNTPResponse.parse(c[:raw])
      resp.code.should eq(c[:code])
      resp.message.should eql(c[:message])
    end
  end
end
