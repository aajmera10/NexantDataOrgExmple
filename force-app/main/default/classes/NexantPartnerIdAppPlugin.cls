global class NexantPartnerIdAppPlugin extends Auth.ConnectedAppPlugin
{ 
    // Return a user’s contact account externalId          
    global override Map<String,String> customAttributes(Id userId, Id connectedAppId, Map<String,String>
        formulaDefinedAttributes, Auth.InvocationContext context)         
    {  
        List<User> userList = [select partner_id__c from user where (Id = :userId)];
        String partnerId = userList[0].partner_id__c;
        formulaDefinedAttributes.put('PARTNERID', partnerId);
        return formulaDefinedAttributes;     
    } 
}