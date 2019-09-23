@RestResource(urlMapping = '/FindTA/*')
global with sharing class FindTARest {

	public static final String QUERY_PARAM_ID = 'id';
	public static final String QUERY_PARAM_NAME = 'name';
	public static final String QUERY_PARAM_SECTOR = 'sector';
	public static final String QUERY_PARAM_SPECIALTIES = 'specialties';
	public static final String QUERY_PARAM_BUSINESS_TYPE = 'type';
	public static final String QUERY_PARAM_TIER = 'tier';
	public static final String QUERY_PARAM_CONTRACTED = 'contracted';

	/**
	 * Allowed combinations of parameters:
	 * 1. No parameter at all
	 * 2. sector and specialties must NOT be empty, others are optional
	 */
	@HttpGet
	global static void searchTradeAllies() {
        //Get request query parameters
		RestRequest req = RestContext.request;
		String taId = req.params.get(QUERY_PARAM_ID);
		String companyName = req.params.get(QUERY_PARAM_NAME);
        String address = req.params.get('address');
		String sector = req.params.get(QUERY_PARAM_SECTOR);
		String businessTypes = req.params.get(QUERY_PARAM_BUSINESS_TYPE);
		String latitude = req.params.get('latitude');
		String longitude = req.params.get('longitude');
		String specialties = req.params.get(QUERY_PARAM_SPECIALTIES);
		String participatingStates = req.params.get('territories');
		String radius = req.params.get('radius');
		String tier = req.params.get(QUERY_PARAM_TIER) == 'true' ? 'Special' : '';
		Boolean contractSigned = req.params.get(QUERY_PARAM_CONTRACTED) == 'true' ? true : false;
        //Audit wrapper
		SearchRequestWrapper wrapper = new SearchRequestWrapper();
        List<SingleFilterInfoWrapper__c> filterList = new List<SingleFilterInfoWrapper__c>();
        //Construct query and populate audit wrapper
		String query = constructQuery
		(taId, radius, companyName, sector, businessTypes, latitude, longitude, specialties, participatingStates, tier, contractSigned, filterList);
		wrapper.listOfFilters = filterList;
        List<Account> result = null;
        if(query != null) {
			result = Database.query(query);
        }
        //System.debug(String.valueOf(result));
        RestContext.response.addHeader('Content-Type', 'application/json');
    	RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(result));
    	//return result;
	}      

	private static String constructQuery(String taId, String radius, String companyName, String sector, String businessTypes, String latitude, String longitude, String specialties, String participatingStates, String tier, Boolean contractSigned, List<SingleFilterInfoWrapper__c> filterList) {
        Boolean specialtyRequested = false;
        Boolean stateRequested = false;
        List<String> accountIds = new List<String>();
        List<String> accountIdsStates = new List<String>();
        List<String> accountIdsSpecialties = new List<String>();
        if(specialties != null && specialties.length()> 0) {
            specialtyRequested = true;
            Set<String> accountIdSet = getSpecialtyAccountIds(specialties, sector, filterList);
            accountIdsSpecialties.addAll(accountIdSet);
            if(accountIdsSpecialties.size() == 0) {
                  //This means that the user sent in specialties in the params list, but nothing matching those values was found
                  //In this case, we don't need to query for anything else
                  return null;
            }
        }
        if(participatingStates != null && participatingStates.length()> 0) {
            stateRequested = true;
            Set<String> accountIdSet = getStatesAccountIds(participatingStates, filterList);
            accountIdsStates.addAll(accountIdSet);
            if(accountIdsStates.size() == 0) {
                //This means that the user sent in states in the params list, but nothing matching those values was found
                //In this case, we don't need to query for anything else
                return null;
        	}
        }
        if(specialtyRequested && stateRequested)
        	accountIds.addAll(intersect(accountIdsStates, accountIdsSpecialties));
        else if(specialtyRequested && !stateRequested)
            accountIds.addAll(accountIdsSpecialties);
        else if(!specialtyRequested && stateRequested)
            accountIds.addAll(accountIdsStates);
        
        Boolean whereConditionAdded = false;
				String query = 'SELECT Id, Name, Tier_Level__c, Contract_Signed__c, Projects_Completed__c, Rating, Business_Type__c, BillingLatitude, BillingLongitude, Phone, Website, BillingStreet, BillingCity, BillingState, BillingPostalCode, (Select name, email, phone from Contacts), (Select Specialty__r.Name, Specialty__r.Sector__c from Trade_Ally_Specialties__r), (Select Territory__r.Name, Territory__r.Territory_Type__c from Territory_Assignments__r), (Select Demographic__c.id, Demographic__c.Languages_spoken_other_than_English__c from Demographics__r) FROM Account ';
        if (latitude != null && latitude.length() > 0) {
            addFilterToList('latitude', latitude, filterList);
			if (longitude != null && longitude.length() > 0) {
                addFilterToList('longitude', longitude, filterList);
                System.debug('radius: '+radius);
                if(radius != null && radius.length() > 0) {
                    addFilterToList('radius', radius, filterList);
					query = query + 'WHERE DISTANCE(BillingAddress, GEOLOCATION(' + Decimal.valueOf(latitude) + ',' + Decimal.valueOf(longitude) + '), \'mi\') < '+ Decimal.valueOf(radius);
					whereConditionAdded = true;
                }
			}
		}

		if (taId != null && taId.length() > 0) {
			addFilterToList('taId', taId, filterList);
			if (whereConditionAdded) {
				query = query + ' AND ';
			} else {
				query = query + ' WHERE ';
				whereConditionAdded = true;
			}
			query = query + ' Id = :taId';
		}

		if (companyName != null && companyName.length() > 0) {
            addFilterToList('companyName', companyName, filterList);
			if (whereConditionAdded)
			query = query + ' AND ';
			else {
				query = query + ' WHERE ';
				whereConditionAdded = true;
			}
			query = query + 'Name = :companyName';
		}
		if (businessTypes != null && businessTypes.length()> 0) {
            addFilterToList('businessTypes', businessTypes, filterList);
			businessTypes = String.escapesinglequotes(businessTypes);
			List<String> businessTypeList = businessTypes.split(',');
			if (whereConditionAdded)
			query = query + ' AND ';
			else {
				query = query + ' WHERE ';
				whereConditionAdded = true;
			}
			query = query + 'Business_Type__c INCLUDES (';
			for (integer i = 0; i<businessTypeList.size(); i++) {
				query = query + '\'' + businessTypeList[i] + '\'';
				if (i != businessTypeList.size() - 1)
				query = query + ',';
			}
			query = query + ')';
		}
        //Check for enable contractor search box
        if (whereConditionAdded)
			query = query + ' AND Search_Enabled__c = true';
		else {
			query = query + ' WHERE Search_Enabled__c = true';
			whereConditionAdded = true;
		}

		//Check for premium tier 
		if (tier == 'Special') {
			if (whereConditionAdded) {
				query = query + ' AND Tier_Level__c = \'Special\'';
			} else {
				query = query + ' WHERE Tier_Level__c = \'Special\'';
				whereConditionAdded = true;
			}
		}

		// Check for contract signed
		if (contractSigned) {
			if (whereConditionAdded) {
				query = query + ' AND Contract_Signed__c = true';
			} else {
				query = query + ' WHERE Contract_Signed__c = true';
				whereConditionAdded = true;
			}
		}

        //Check for the record type of TA
        if (whereConditionAdded)
			query = query + ' AND RecordType.Name = \'Trade Ally\'';
		else {
			query = query + ' WHERE RecordType.Name =\'Trade Ally\'';
			whereConditionAdded = true;
		}
		if(accountIds.size() > 0) {
			if (whereConditionAdded)
			query = query + ' AND ';
			else {
				query = query + ' WHERE ';
				whereConditionAdded = true;
			}
			query = query + 'ID IN (';
			for (integer i = 0; i < accountIds.size(); i++) {
				query = query + '\'' + accountIds[i] + '\'';
				if (i != accountIds.size() - 1)
				query = query + ',';
			}
			query = query + ')';
		}
		System.debug('query '+query);
		return query;
	}
    
    private static Set<String> getSpecialtyAccountIds(String specialties, String sector, List<SingleFilterInfoWrapper__c> filterList) {
        Set<String> accountIdSet = new Set<String>();
        System.debug('specialties '+specialties);
        if (specialties != null && specialties.length()> 0 && sector != null && sector.length() > 0) {
            addFilterToList('specialties', specialties, filterList);
			specialties = String.escapesinglequotes(specialties);
			List<String> specialtyList = specialties.split(',');
			List<String> sectorList = sector.split(',');
			String queryForId = 'SELECT Trade_Ally__c from Trade_Ally_Specialty__c where Specialty__r.Name IN (';
			for (integer i = 0; i<specialtyList.size(); i++) {
				queryForId = queryForId + '\'' + specialtyList[i] + '\'';
				if (i != specialtyList.size() - 1)
				queryForId = queryForId + ',';
			}
			queryForId = queryForId + ')';

			queryForId = queryForId + ' AND Specialty__r.Sector__c IN (';
			for (integer i = 0; i<sectorList.size(); i++) {
				queryForId = queryForId + '\'' + sectorList[i] + '\'';
				if (i != sectorList.size() - 1)
					queryForId = queryForId + ',';
			}
			queryForId = queryForId + ')';
			System.debug('[getSpecialtyAccountIds] queryForId = ' + queryForId);
			List<sObject> result = Database.query(queryForId);
			for(SObject s:result) {
				accountIdSet.add(String.valueOf(s.get('Trade_Ally__c')));
			}
		}
        return accountIdSet;
    }
    
    private static Set<String> getStatesAccountIds(String participatingStates, List<SingleFilterInfoWrapper__c> filterList) {
        Set<String> accountIdSet = new Set<String>();
        System.debug('participatingStates '+participatingStates);
		if (participatingStates != null && participatingStates.length()> 0) {
            addFilterToList('participatingStates', participatingStates, filterList);
			participatingStates = String.escapesinglequotes(participatingStates);
			List<String> stateList = participatingStates.split(',');
			// YH (2019-03-15): FTA sends Territory__r.Id 
			String queryForId = 'SELECT Trade_Ally__c FROM Territory_Assignment__c where Territory__r.Id IN (';
			for (integer i = 0; i<stateList.size(); i++) {
				queryForId = queryForId + '\'' + stateList[i] + '\'';
				if (i != stateList.size() - 1)
				queryForId = queryForId + ',';
			}
			queryForId = queryForId + ')';
			List<sObject> result = Database.query(queryForId);
			for(SObject s:result) {
				accountIdSet.add(String.valueOf(s.get('Trade_Ally__c')));
			}
		}
        return accountIdSet;
    }
    
    private static void addFilterToList(String filterName, String filterValue, List<SingleFilterInfoWrapper__c> filterList) {
        	SingleFilterInfoWrapper__c singleFilter = new SingleFilterInfoWrapper__c();
            singleFilter.Filter_Name__c = filterName;
            singleFilter.Value_String__c = filterValue;
            filterList.add(singleFilter);
    }
    
    private static List<String> intersect(List<String> listA, List<String> listB) {
        List<String> resultList = new List<String>();
        for(String str : listA) {
            if(listB.contains(str)) {
                resultList.add(str);
            }
        }
        return resultList;
    }
}