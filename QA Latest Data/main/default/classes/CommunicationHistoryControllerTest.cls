@isTest
private class CommunicationHistoryControllerTest {

	@isTest
	private static void testGetCommunicationHistoryResults() {
		createTaskList();
		List<Task> resultTaskList = CommunicationHistoryController.getCommunicationHistoryResults();
		verifyResults(resultTaskList);
	}

	private static void createTaskList() {
		List<Task> resultTaskList = new List<Task>();
		Task t;

		for (Integer i = 0; i < 10; i++) {
			t = new Task();
			t.Subject = 'test' + i;
			t.Description = 'test Task';
			resultTaskList.add(t);
		}
		
		insert resultTaskList;
	}

	private static void verifyResults(List<Task> resultTaskList) {
		System.assert(resultTaskList != null);
		System.assert(resultTaskList.size() == 10);
	}
}