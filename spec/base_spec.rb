require "spec_helper"

describe "Base" do
  describe "#get" do
    before do
      stub_request(:get, "http://google.com/bases")
        .with(headers: {authorization: "Bearer asdf"})
        .to_return(body: {a: "b"}.to_json)
    end

    it "finds something" do
      response = GlobalRegistry::Base.get
      expect(response).to be_a Hash
    end

    it "can be configured" do
      @custom_gr_url = stub_request(:get, "https://cru.org/bases")
        .with(headers: {authorization: "Bearer qwer",
                        "X-Forwarded-For": "203.0.113.7"})
        .to_return(body: {a: "b"}.to_json)
      gr = GlobalRegistry::Base.new(access_token: "qwer", base_url: "https://cru.org", xff: "203.0.113.7")
      expect(gr.get).to be_a Hash
      expect(@custom_gr_url).to have_been_requested
    end
  end

  describe "#get_all_pages" do
    it "aggregates results from all pages" do
      stub_page_results

      expect(GlobalRegistry::Base.new(access_token: "asdf").get_all_pages)
        .to eq([{"id" => "1"}, {"id" => "2"}])
    end

    it "yields results if given a block" do
      stub_page_results

      expect do |b|
        GlobalRegistry::Base.new(access_token: "asdf").get_all_pages.each(&b)
      end.to yield_successive_args({"id" => "1"}, {"id" => "2"})
    end

    def stub_page_results
      page1 = {
        entity_types: [{id: "1"}],
        meta: {page: 1, next_page: true, from: 1, to: 1}
      }
      page2 = {
        entity_types: [{id: "2"}],
        meta: {page: 2, next_page: false, from: 2, to: 2}
      }
      stub_request(:get, "http://google.com/bases")
        .with(headers: {authorization: "Bearer asdf"})
        .to_return(body: page1.to_json)
      stub_request(:get, "http://google.com/bases?page=2")
        .with(headers: {authorization: "Bearer asdf"})
        .to_return(body: page2.to_json)
    end
  end

  describe "#find" do
    it "correctly handles array params" do
      @custom_gr_url = stub_request(:get, "http://google.com/bases/1?a[]=b&a[]=c")
      GlobalRegistry::Base.find(1, "a[]": ["b", "c"])
      expect(@custom_gr_url).to have_been_requested
    end
  end
end
