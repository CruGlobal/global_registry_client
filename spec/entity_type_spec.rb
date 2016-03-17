require 'spec_helper'

describe GlobalRegistry::EntityType do
  context '#for_names' do
    it 'retrieves the entity types filtered by name' do
      url = "http://google.com/entity_types?"\
        "filters[name][]=ministry&filters[name][]=person"
       stub_request(:get, url)
         .with(:headers => {'Authorization'=>'Bearer asdf'})
         .to_return(body: { entity_types: [{ id: '1f' }] }.to_json)

      types = GlobalRegistry::EntityType.for_names(%w(ministry person))

      expect(types).to eq([{ 'id' => '1f' }])
    end
  end
end
