@IsTest
private class WrappedInfoParserTest {
	@IsTest
	static void testBehavior() {
		Account newAccount = new Account(
				Name = 'newAccount'
		);
		insert newAccount;
		String sObjectType = 'Specialty__c';
		String sObjectJunctionType = 'Trade_Ally_Specialty__c';
		Id tradeAllyId = newAccount.Id;
		String label = 'Participating Programs';
		String junctionFieldName = 'Specialty__c';
		FieldInfoWrapper newWrapper = new FieldInfoWrapper(
		 sObjectType,
		 sObjectJunctionType,
		 tradeAllyId,
		 label,
		 junctionFieldName
		);
		WrappedInfoParser.addItemToListOfSpecialFields(newWrapper);
		WrappedInfoParser.workWithSpesialFields();
        System.assertEquals(WrappedInfoParser.listOfSpecialFields.size(), 1);
	}
}