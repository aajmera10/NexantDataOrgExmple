@isTest
private class NewCommunicationControllerTest {

	@isTest
	private static void testNewCommunication() {
		Task t = createTestTask();
		String taskJSON = JSON.serialize(t);
		NewCommunicationController.createNewCommunication(taskJSON);
		verifyCommunicationWasCreated();
	}

	@isTest
	private static void testFieldsWrapper() {
		NewCommunicationController.TaskFieldsWrapper fieldsWrapper = NewCommunicationController.prepareTaskFieldOptionsInfo();
		System.assert(fieldsWrapper != null);
	}

	private static Task createTestTask() {
		Task t = new Task();
		t.Subject = 'test';
		t.Description = 'test task';
		return t;
	}

	private static void verifyCommunicationWasCreated() {
		List<Task> createdCommunicationList = [
			SELECT Id, 
				   Subject 
			FROM   Task 
			LIMIT  100
		];
		System.assert(!createdCommunicationList.isEmpty());
	}
}