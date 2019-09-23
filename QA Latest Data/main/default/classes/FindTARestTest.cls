@IsTest
private class FindTARestTest  {
    @isTest static void testSearchComprehensive() {
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://tradeallydev-dev-ed.my.salesforce.com/services/apexrest/FindTA';
        request.httpMethod = 'GET';
        request.params.put('name', 'sForce');
        request.params.put(FindTARest.QUERY_PARAM_SECTOR, 'Commercial');
        request.params.put(FindTARest.QUERY_PARAM_BUSINESS_TYPE, 'Contractor,Manufacturing');
        request.params.put('specialties', 'Lighting,Appliances');
        request.params.put('states', 'a0Kf4000005lHKIEA2'); // a0Kf4000005lHKIEA2 is CA
        request.params.put('latitude', '37.775');
        request.params.put('longitude', '-122.418');
        request.params.put('radius', '50');
		request.params.put('contracted', 'true');
		request.params.put('tier', 'true');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        // Call the method to test
        FindTARest.searchTradeAllies();
        // Verify results
        System.assert(RestContext.response.responseBody != null);
    }

	// Test searching without any parameter. This is the default query for FTA to get ALL records from TAC
	@isTest static void testSearchWithoutParam () {
		RestRequest request = new RestRequest();
        request.requestUri =
            'https://tradeallydev-dev-ed.my.salesforce.com/services/apexrest/FindTA';
		request.httpMethod = 'GET';
		RestContext.request = request;
        RestContext.response = new RestResponse();
        // Call the method to test
        FindTARest.searchTradeAllies();
        // Verify results
        System.assert(RestContext.response.responseBody != null);
	}

	// Test searching with valid sector-specialty combination
	@isTest static void testSearchWithSectorAndSpecailty() {
		RestRequest request = new RestRequest();
        request.requestUri = 'https://tradeallydev-dev-ed.my.salesforce.com/services/apexrest/FindTA';
        request.httpMethod = 'GET';
        request.params.put(FindTARest.QUERY_PARAM_SECTOR, 'Agriculture');
		request.params.put(FindTARest.QUERY_PARAM_SPECIALTIES, 'Irrigation'); // YHOU: by 2019-03-26, this should return at least 5 results
		RestContext.request = request;
		RestContext.response = new RestResponse();
		FindTARest.searchTradeAllies();
        System.assert(RestContext.response.responseBody != null);
	}

	// Test searching with valid tier and contract status
	@isTest static void testSearchWithTierAndContractStatus() {
		RestRequest request = new RestRequest();
        request.requestUri = 'https://tradeallydev-dev-ed.my.salesforce.com/services/apexrest/FindTA';
        request.httpMethod = 'GET';
        request.params.put(FindTARest.QUERY_PARAM_TIER, 'true');
		request.params.put(FindTARest.QUERY_PARAM_CONTRACTED, 'true'); // YHOU: by 2019-03-26, this should return at least 5 results
		RestContext.request = request;
		RestContext.response = new RestResponse();
		FindTARest.searchTradeAllies();
        System.assert(RestContext.response.responseBody != null);
	}
}