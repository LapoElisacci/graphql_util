RSpec.describe GraphqlUtil do
  it 'has a version number' do
    expect(GraphqlUtil::VERSION).not_to be nil
  end

  context 'Client', :vcr do
    class TestClient
      GraphqlUtil.act_as_graphql_client(
        self, # Required
        endpoint: 'https://api.spacex.land/graphql', # Required
        path: __dir__, # Required, (Recommended: __dir__)
        headers: {} # Optional
      )
    end

    it 'Defines the expected query method' do
      expect(TestClient.methods.include?(:launches_past)).to eq(true)
    end

    it 'Works' do
      res = TestClient.launches_past(limit: 2)
      res_hash = res.to_h
      expect(res_hash['data']['launchesPast'].count).to eq(2)
    end
  end
end
