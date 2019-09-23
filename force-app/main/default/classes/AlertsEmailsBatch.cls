global class AlertsEmailsBatch implements Database.Batchable<SObject> {

	private static Map<String,EmailTemplate> mapOfTemplates {
		get {
			if (mapOfTemplates == null) {
				mapOfTemplates = new Map<String,EmailTemplate>();
				List<EmailTemplate> listOfTemplates = [
					SELECT
							Id,
							Name,
                    		Body,
                    		Subject,
                    		HTMLValue
					FROM	EmailTemplate
					WHERE	Name IN: Constants.SET_OF_TEMPLATES_NAMES
				];
				for (EmailTemplate template : listOfTemplates) {
					mapOfTemplates.put(
						template.Name.split(' ')[0],
						template
					);
				}
			}
			return mapOfTemplates;
		}
		set;
	}
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		/*Application_Settings__c applicationSettings = Application_Settings__c.getValues(Constants.ALERTS_REVIEW);
		Set<Integer> setOfDates = new Set<Integer>();
		if (
			applicationSettings != null && 
			applicationSettings.Value__c != null && 
			applicationSettings.Value__c.trim() != ''
		) {
			for (String value : applicationSettings.Value__c.split(',')) {
				if (value.trim().isNumeric()) {
					setOfDates.add(
						Integer.valueOf(
							value.trim()
						)
					);
				}
			}
		}
		//String query = 'SELECT Id, Name, Alert_Expiration_Date__c, Alert_Message__c, Alert_Title__c FROM Alert__c WHERE ';
		String query = 'SELECT Id, ActivityDate, Description, Subject FROM Task WHERE Type = \'Alert\' AND (';
		if (setOfDates.isEmpty()) {
			setOfDates.addAll(Constants.DEFAULT_ALERTS_DAYS);
		}
		Date today = Date.today();
		Datetime comparationDate;
		for (Integer days : setOfDates) {
			comparationDate = Datetime.newInstance(
				today.addDays(-days),
				Time.newInstance(0, 0, 0, 0)
			);
			//query += 'ActivityDate = \'' + comparationDate.format() + '\' OR ';
			query += 'ActivityDate = ' + comparationDate.format('YYYY-MM-dd') + ' OR ';
		}
		return Database.getQueryLocator(query.removeEnd(' OR ') + ')');*/
		String query = 'SELECT Id, WhatId, ownerId, ActivityDate, Description, Subject FROM Task WHERE Type = \'Alert\' AND (';
		query += getDatesBasedPartOfQuery(Constants.ALERTS_INCURANCE_EMAIL,'Insurance') + ' OR ';
		query += getDatesBasedPartOfQuery(Constants.ALERTS_LICENSE_EMAIL,'License') + ' OR ';
		query += getDatesBasedPartOfQuery(Constants.ALERTS_CERTIFICATION_EMAIL,'Certification') + ')';
		System.debug(query);
		Database.QueryLocator ql;
		if (
			ESAPI.securityUtils().isAuthorizedToView(
				'Task',
				new List<String>{
					'Id',
                    'WhatId',
                    'ownerId',
					'ActivityDate',
					'Description',
					'Subject'
				}
			)
		) {
			ql = Database.getQueryLocator(query);
		}
		return ql;
	}

	public static Set<Integer> getSetOfDates(String recordName) {
		Set<Integer> setOfDates = new Set<Integer>();
		Application_Settings__c applicationSettings = Application_Settings__c.getValues(recordName);
		if (
			applicationSettings != null && 
			applicationSettings.Value__c != null && 
			applicationSettings.Value__c.trim() != ''
		) {
			for (String value : applicationSettings.Value__c.split(',')) {
				if (value.trim().isNumeric()) {
					setOfDates.add(
						Integer.valueOf(
							value.trim()
						)
					);
				}
			}
		}
		if (setOfDates.isEmpty()) {
			setOfDates.addAll(Constants.DEFAULT_ALERTS_DAYS);
		}
		return setOfDates;
	}

	private String getDatesBasedPartOfQuery(String recordName, String typeOfObject) {
		String query = '((';
		Date today = Date.today();
		Datetime comparationDate;
		for (Integer days : getSetOfDates(recordName)) {
			comparationDate = Datetime.newInstance(
				today.addDays(days),
				Time.newInstance(0, 0, 0, 0)
			);
			//query += 'ActivityDate = \'' + comparationDate.format() + '\' OR ';
			query += 'ActivityDate = ' + comparationDate.format('YYYY-MM-dd') + ' OR ';
		}
		return query.removeEnd(' OR ') + ') AND Subject LIKE \'' + String.escapeSingleQuotes(typeOfObject) + '%\')';
	}
    
    private String getContactId(Id userId, List<User> userList) {
        for(User user:userList) {
            if(user.Id == userId) {
                return user.contactId;
            }
        }
        return null;
    }

   	global void execute(Database.BatchableContext context, List<Task> scope) {
        String senderName = 'No Reply';
		List<Messaging.SingleEmailMessage> listOfEmails = new List<Messaging.SingleEmailMessage>();
        Application_Settings__c applicationSettings = Application_Settings__c.getValues(Constants.EMAIL_SENDER_DISPLAY_NAME);
        if (
			applicationSettings != null && 
			applicationSettings.Value__c != null && 
			applicationSettings.Value__c.trim() != ''
		) {
			senderName = applicationSettings.Value__c;
        }
        List<Id> userIdList = new List<Id>();
        for (Task alert : scope) {
            userIdList.add(alert.ownerId);
        }
        List<User> users = [Select Id, ContactId from User where Id IN :userIdList];
        System.debug(users);
		for (Task alert : scope) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            EmailTemplate template = mapOfTemplates.get(alert.Subject.split(' ')[0]);
			mail.setTemplateId(template.id);
            mail.setSubject(template.Subject);
			//mail.setSubject(alert.Subject);
			mail.setTargetObjectId(getContactId(alert.ownerId, users));
			mail.setTreatTargetObjectAsRecipient(false);
			mail.setWhatId(alert.WhatId);
			mail.setSaveAsActivity(false);
			mail.setToAddresses(new List<String>{alert.OwnerId});
			mail.setReplyTo('no-reply@tradeally.com');
			mail.setSenderDisplayName(senderName);
            mail.setTreatBodiesAsTemplate(true);
            String str = template.HtmlValue;
            System.debug('*******'+str);
            str = str.replaceAll('<!\\[CDATA\\[', '');
			str= str.replaceAll('\\]\\]>', '');
            mail.setHTMLBody(str);

			listOfEmails.add(mail);
		}
		Messaging.sendEmail(listOfEmails);
	}
	
	global void finish(Database.BatchableContext context) {
		
	}
}