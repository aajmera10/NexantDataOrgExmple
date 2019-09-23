public with sharing class CustomProfileMenuController {

	private static User getUserInfo() {
		User u;
		List<String> fieldsToCheck = new List<String>{
			'Id',
			'ContactId',
			'Name',
			'SmallPhotoUrl'
		};
		System.debug(ESAPI.securityUtils().isAuthorizedToView('User',fieldsToCheck));
		System.debug(ESAPI.securityUtils().isAuthorizedToView('Contact',new List<String>{'AccountId'}));
		if (
			ESAPI.securityUtils().isAuthorizedToView('User',fieldsToCheck) &&
			ESAPI.securityUtils().isAuthorizedToView('Contact',new List<String>{'AccountId'})
		) {
			u = [
				SELECT
						Id,
						Name,
						Profile.Name,
						Contact.AccountId,
						SmallPhotoUrl
				FROM	User
				WHERE	Id =: UserInfo.getUserId()
				LIMIT	1
			];
		}
		return u;
	}

	private static Boolean isNotSubscriped(Id userId) {
		List<PermissionSetAssignment> permissionSetAssignmentList = [
			SELECT
					Id
			FROM    PermissionSetAssignment
			WHERE   
					AssigneeId =: userId AND
					PermissionSetId IN (
						SELECT	Id
						FROM    PermissionSet
						WHERE   IsOwnedByProfile = false
					)
		];
		return permissionSetAssignmentList.isEmpty();
	}

	private static final List<String> listOfPossibleItems = new List<String>{
		'Home',
		'My Profile',
		'My Settings',
		'My Account',
		'My Subscription',
		'Contact Support',
		'Logout'
	};

	private static final Map<String,Set<String>> mapOfAssignments = new Map<String,Set<String>>{
		'Home' => new Set<String>{'Admin','CommunityUser','No Subscription'},
		'My Profile' => new Set<String>{'Admin','CommunityUser','No Subscription'},
		'My Settings' => new Set<String>{'Admin','CommunityUser','No Subscription'},
		'My Account' => new Set<String>{'CommunityUser','No Subscription'},
		'My Subscription' => new Set<String>{'No Subscription'},
		'Contact Support' => new Set<String>{'Admin','CommunityUser','No Subscription'},
		'Logout' => new Set<String>{'Admin','CommunityUser','No Subscription'}
	};

	@AuraEnabled
	public static AllInfoWrapper prepareProfileMenuData() {
		String userType = 'Admin';
		User u = getUserInfo();
		if (u.Profile.Name != 'System Administrator') {
			userType = 'CommunityUser';
			if (isNotSubscriped(u.Id)) {
				userType = 'No Subscription';
			}
		}
		List<String> listOfItems = new List<String>();
		for (String item : listOfPossibleItems) {
			if (mapOfAssignments.get(item).contains(userType)) {
				listOfItems.add(item);
			}
		}
		return new AllInfoWrapper(
			listOfItems,
			u.Id,
			u.Contact.AccountId,
			u.Name,
			u.SmallPhotoUrl
		);
	}

	public class AllInfoWrapper {
		@AuraEnabled public List<String> listOfItems {get;set;}
		@AuraEnabled public String userId {get;set;}
		@AuraEnabled public String accountId {get;set;}
		@AuraEnabled public String userName {get;set;}
		@AuraEnabled public String photoURL {get;set;}

		public AllInfoWrapper(
			List<String> listOfItems,
			String userId,
			String accountId,
			String userName,
			String photoURL
		) {
			this.listOfItems = listOfItems;
			this.userId = userId;
			this.accountId = accountId;
			this.userName = userName;
			this.photoURL = photoURL;
		}
	}
}