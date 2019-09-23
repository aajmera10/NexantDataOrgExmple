public class ExternalLinkController {
    @testVisible
    private class JWT_Metadata_Missing_Exception extends Exception {}
    @AuraEnabled
    public static String getLink() {
        List<JWT_Settings_Object__mdt> jwtSettingsObjects;
        JWT_Settings_Object__mdt jwtSettingsObject;
        String sharedSecret;
        String externalUrl;
        if (ESAPI.securityUtils().isAuthorizedToView(Constants.NAMESPACE + 'JWT_Settings_Object__mdt', new List<String>{
            'Id', Constants.NAMESPACE + 'Shared_Secret__c', Constants.NAMESPACE + 'Url_Address__c'})) {
                jwtSettingsObjects = [
                    SELECT 
                    Id,
                    Shared_Secret__c,
                    Url_Address__c
                    FROM JWT_Settings_Object__mdt
                ];
            }
        if(jwtSettingsObjects.size() > 0) {
            jwtSettingsObject = jwtSettingsObjects[0];
            if(jwtSettingsObject != null){
                sharedSecret = jwtSettingsObject.Shared_Secret__c;
                externalUrl = jwtSettingsObject.Url_Address__c;
            }
        } 
        if(sharedSecret == null || externalUrl == null){
            System.debug('No JWT Settings metadata object found to retrieve the shared secret!');
            throw new JWT_Metadata_Missing_Exception('No JWT Settings metadata object found to retrieve the shared secret!');
        }
        String jwtToken = getJwtToken(sharedSecret);
        String externalLink = externalUrl+jwtToken;
        System.debug(externalLink);
        return externalLink;
    }
    @AuraEnabled
    public static String getJwtToken(String sharedSecret) {
        CustomJwt jwt = new CustomJwt('HS256');
        //Additional claims to set scope
        Map<String, String> claims = new Map<String, String>();
        String sub = UserInfo.getUserName();
        String firstName = UserInfo.getFirstName();
        String lastName = UserInfo.getLastName();
        String email = UserInfo.getUserEmail();
        //Get the partner id of User's TA Account
        List<User> userList = [SELECT Id, Partner_Id__c From User where Username = :sub];
        String partnernumber = userList.get(0).Partner_Id__c;
        //Get the account name from partner id
        if(partnernumber != null) {
            claims.put('partnernumber', partnernumber);
            List<Account> acctList = [SELECT Id, name From Account where External_Id__c = :partnernumber];
            System.debug('acctList>>>'+acctList);
            String partnername = acctList.get(0).name;
            claims.put('partnername', partnername);
        }
        jwt.sub = sub;
        jwt.iss = 'tac';
        jwt.aud = 'DSMC';
        claims.put('firstname', firstName);
        claims.put('lastname', lastName);
        claims.put('email', email);
        jwt.claims = claims;
        jwt.privateKey = sharedSecret;
        String token = jwt.issue();
        System.debug(token);
        return token;
        /*CustomJwt jwt1 = new CustomJwt('HS256');
jwt1.sub = 'jbrown@testabc.com';
jwt1.iss = 'tac';
jwt1.aud = 'DSMC';
Map<String, String> claims = new Map<String, String>();
claims.put('firstname', 'Joe');
claims.put('lastname', 'Brown');
claims.put('email', 'jbrown@testabc.com');
claims.put('partnernumber', 'P101');
claims.put('partnername', 'DEF Services');
jwt1.claims = claims;
jwt1.privateKey = sharedSecret;
return jwt1.issue();*/
    }
}