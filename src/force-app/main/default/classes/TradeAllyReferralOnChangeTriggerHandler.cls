public with sharing class TradeAllyReferralOnChangeTriggerHandler {
	
	public static void checkAndUpdateStatus(
		List<Trade_Ally_Referral__c> listOfNewReferrals, 
		Map<Id,Trade_Ally_Referral__c> mapOfOldReferrals, 
		Boolean isInsert
	) {
		Set<Id> setOfTradeAlliesIds = new Set<Id>();
		List<Trade_Ally_Referral__c> listOfReferralsToSendEmail = new List<Trade_Ally_Referral__c>();
		Id currentUserAccountId = getCurrentUserAccountId();
		for (Trade_Ally_Referral__c referral : listOfNewReferrals) {
			if (
				(
					mapOfOldReferrals == null || 
					mapOfOldReferrals.get(referral.Id).Trade_Ally__c != referral.Trade_Ally__c
				) &&
				(
					referral.Referral_Status__c == null ||
					Constants.SET_OF_BAD_STATUSES.contains(referral.Referral_Status__c)
				)
			) {
				referral.addError('Referrals with status \'Customer Contacted\', \'Converted\' or \'Closed\' and assigned/reassigned');
			} else if (
				isInsert || 
				(
					mapOfOldReferrals.get(referral.Id).Referral_Status__c == referral.Referral_Status__c &&
					mapOfOldReferrals.get(referral.Id).Trade_Ally__c != referral.Trade_Ally__c && 
					referral.Referral_Status__c != 'Expired'
				)
			) {
				//referral.Referral_Status__c = 'Customer Contacted';
				referral.Referral_Status__c = 'Assigned';
				setOfTradeAlliesIds.add(referral.Trade_Ally__c);
				listOfReferralsToSendEmail.add(referral);
			} else if (
				currentUserAccountId != null &&
				referral.Trade_Ally__c == currentUserAccountId
			) {
				referral.Referral_Status__c = 'Customer Contacted';
			}
		}
		if (!listOfReferralsToSendEmail.isEmpty()) {
			sendContactedEmails(listOfReferralsToSendEmail,setOfTradeAlliesIds);
		}
	}

	private static Id getCurrentUserAccountId() {
		User u = [
			SELECT	Contact.AccountId
			FROM	User
			WHERE	Id =: UserInfo.getUserId()
		];
		return u.Contact.AccountId;
	}

	private static void sendContactedEmails(
		List<Trade_Ally_Referral__c> listOfReferralsToSendEmail,
		Set<Id> setOfTradeAlliesIds
	) {
		List<Messaging.SingleEmailMessage> listOfEmails = new List<Messaging.SingleEmailMessage>();
		Messaging.SingleEmailMessage mail;
		EmailTemplate template = [
			SELECT	Id
			FROM	EmailTemplate
			WHERE	Name =: Constants.NOTIFICATION_TEMPLATE
			LIMIT	1
		];
		List<Contact> listOfPrimaryContacts = [
			SELECT	
					Id,
					AccountId,
					Email
			FROM	Contact
			WHERE
					Level__c = 'Primary' AND
					AccountId IN: setOfTradeAlliesIds
		];
		Map<Id,List<Contact>> mapOfPrimaryContactsByTAId = new Map<Id,List<Contact>>();
		List<Contact> tempListOfPrimaryContacts;
		for (Contact c : listOfPrimaryContacts) {
			tempListOfPrimaryContacts = mapOfPrimaryContactsByTAId.get(c.AccountId);
			if (tempListOfPrimaryContacts == null) {
				tempListOfPrimaryContacts = new List<Contact>();
			}
			tempListOfPrimaryContacts.add(c);
			mapOfPrimaryContactsByTAId.put(
				c.AccountId,
				tempListOfPrimaryContacts
			);
		}
		for (Trade_Ally_Referral__c r : listOfReferralsToSendEmail) {
			if (mapOfPrimaryContactsByTAId.get(r.Trade_Ally__c) != null) {
				for (Contact c : mapOfPrimaryContactsByTAId.get(r.Trade_Ally__c)) {
					mail = new Messaging.SingleEmailMessage();
					mail.setTemplateId(template.Id);
					mail.setTargetObjectId(c.Id);
					mail.setTreatTargetObjectAsRecipient(false);
					mail.setWhatId(r.Id);
					mail.setSaveAsActivity(false);
					mail.setToAddresses(new List<String>{c.Email});
					mail.setReplyTo('no-replay@salesforce.com');
					mail.setSenderDisplayName('No Replay');
					listOfEmails.add(mail);
				}
			}
		}
		Messaging.sendEmail(listOfEmails);
	}
}