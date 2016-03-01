require 'spec_helper'

describe 'Entity' do
  describe '#get' do
    before do
      stub_request(:get, 'http://google.com/entities')
          .to_return(:body => {a: 'b'}.to_json)
    end

    it 'finds something' do
      response = GlobalRegistry::Entity.get
      expect(response).to be_a Hash
    end

    it 'can be configured' do
      @custom_gr_url = stub_request(:get, 'http://cru.org/entities')
                           .to_return(:body => {a: 'b'}.to_json)
      gr = GlobalRegistry::Entity.new(base_url: 'cru.org')
      expect(gr.get).to be_a Hash
      expect(@custom_gr_url).to have_been_requested
    end
  end

  describe '#put' do
    before do
      stub_request(:get, 'http://google.com/entities')
          .to_return(:body => {a: 'b'}.to_json)
    end

    it 'sends data' do
      response = GlobalRegistry::Entity.get
      expect(response).to be_a Hash
    end
  end
end
