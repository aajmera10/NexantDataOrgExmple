@IsTest
global class StripeHttpCalloutMock  implements HttpCalloutMock {
	// Implement this interface method
	global HttpResponse respond(HttpRequest request) {
		// Create a fake response
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setBody(
				'{"id":"testId", "product":"testProduct", "subscription":"subscription", "data": [{"id":"testId", "product":"testProduct", "name":"testName", "date":"4567896", "amount_paid": 100 , "subscription":"subscription"}, {"id":"testId", "product":"testProduct", "name":"testName", "date":"4567896", "amount_paid":"100"}, {"id":"testId", "product":"testProduct", "name":"testName", "date":"4567896", "amount_paid":"100"}, {"id":"testId", "product":"testProduct", "name":"testName", "date":"4567896", "amount_paid":"100"}, {"id":"testId", "product":"testProduct", "name":"testName", "date":"4567896", "amount_paid":"100"}, {"id":"testId", "product":"testProduct", "name":"testName", "date":"4567896", "amount_paid":"100"}, {"id":"testId", "product":"testProduct", "name":"testName", "date":"4567896", "amount_paid":"100"}, {"id":"testId", "product":"testProduct", "name":"testName", "date":"4567896", "amount_paid":"100"}], "items": {"data": [{"id":"testId", "product":"testProduct", "name":"testName"}]}}');
		response.setStatusCode(200);
		return response;
	}
}