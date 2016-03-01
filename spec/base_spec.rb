require 'spec_helper'

describe 'Base' do
  describe '#get' do
    before do
      stub_request(:get, 'http://google.com/bases')
        .to_return(:status => 200, :body => {a: 'b'}.to_json)
    end
    it 'should find some things' do
      response = GlobalRegistry::Base.get
      expect(response).to be_a Hash
    end
  end
end