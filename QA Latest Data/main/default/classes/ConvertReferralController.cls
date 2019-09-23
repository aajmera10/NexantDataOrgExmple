public with sharing class ConvertReferralController {
    
    @AuraEnabled
    public static Boolean getRecordStatus(String recordId) {
        Trade_Ally_Referral__c taReferral;
        recordId = String.isBlank(recordId) ? null : String.escapeSingleQuotes(recordId);
        if (
            ESAPI.securityUtils().isAuthorizedToView(
                Constants.NAMESPACE + 'Trade_Ally_Referral__c',
                new List<String>{
                    'Id',
                    Constants.NAMESPACE + 'Program__c',
                    Constants.NAMESPACE + 'Referral_Status__c'
                }
            )/* &&
            ESAPI.securityUtils().isAuthorizedToView(
                Constants.NAMESPACE + 'Referral__c',
                new List<String>{
                    'Id',
                    Constants.NAMESPACE + 'Referral_Status__c'
                }
            )*/
        ) {
            taReferral = [
                SELECT  
                        Program__c,
                        Referral_Status__c
                FROM    Trade_Ally_Referral__c
                WHERE   Id =: recordId
            ];
        }
        return (
            (
                taReferral.Referral_Status__c != null &&
                (
                    taReferral.Referral_Status__c == 'Expired' ||
                    taReferral.Referral_Status__c == 'Converted'
                )
            ) ||
            taReferral.Program__c == null
        );
    }

    @AuraEnabled
    public static void startReferralConvertation(String recordId) {
        recordId = String.isBlank(recordId) ? null : String.escapeSingleQuotes(recordId);
        List<Trade_Ally_Referral__c> listOfTAReferrals = new List<Trade_Ally_Referral__c>();
        if (
            ESAPI.securityUtils().isAuthorizedToView(
                Constants.NAMESPACE + 'Trade_Ally_Referral__c',
                new List<String>{
                    'Id',
                    Constants.NAMESPACE + 'Referral__c',
                    Constants.NAMESPACE + 'Trade_Ally__c',
                    Constants.NAMESPACE + 'Program__c',
                    Constants.NAMESPACE + 'Referral_Status__c'
                }
            ) &&
            ESAPI.securityUtils().isAuthorizedToView(
                Constants.NAMESPACE + 'Referral__c',
                new List<String>{
                    'Id',
                    Constants.NAMESPACE + 'Customer__c'
                }
            )
        ) {
            listOfTAReferrals = [
                SELECT  
                        Id,
                        Trade_Ally__c,
                        Program__c,
                        Referral_Status__c,
                        Referral__c,
                        Referral__r.Customer__r.AccountId
                FROM    Trade_Ally_Referral__c
                WHERE   Id =: recordId
            ];
        }
        if (!listOfTAReferrals.isEmpty()) {
            List<Project__c> listOfNewProjects = new List<Project__c>();
            Project__c newProject = new Project__c(
                Referral__c = listOfTAReferrals[0].Referral__c,
                Trade_Ally_Referral__c = recordId,
                //Program__c = listOfTAReferrals[0].Program__c,
                TA_Account__c = listOfTAReferrals[0].Trade_Ally__c,
                Customer_Account__c = listOfTAReferrals[0].Referral__r.Customer__r.AccountId
            );
            ESAPI.securityUtils().validatedInsert(new List<Project__c>{newProject});
            listOfTAReferrals[0].Referral_Status__c = 'Converted';
            ESAPI.securityUtils().validatedUpdate(listOfTAReferrals);
        }
    }
}