require 'spec_helper'

describe 'Base' do
  describe '#get' do
    before do
      stub_request(:get, 'http://google.com/bases')
          .with(headers: {authorization: 'Bearer asdf'})
          .to_return(:body => {a: 'b'}.to_json)
    end

    it 'finds something' do
      response = GlobalRegistry::Base.get
      expect(response).to be_a Hash
    end

    it 'can be configured' do
      @custom_gr_url = stub_request(:get, 'http://cru.org/bases')
                           .with(headers: { authorization: 'Bearer qwer',
                                            'X-Forwarded-For': '203.0.113.7' })
                           .to_return(:body => {a: 'b'}.to_json)
      gr = GlobalRegistry::Base.new(access_token: 'qwer', base_url: 'cru.org', xff: '203.0.113.7')
      expect(gr.get).to be_a Hash
      expect(@custom_gr_url).to have_been_requested
    end
  end
end