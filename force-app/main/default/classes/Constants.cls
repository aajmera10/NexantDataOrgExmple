/**
 * Constants contains data and values that are commonly used across TAC application. 
 */
public with sharing class Constants {

	public static final Set<String> SET_OF_BAD_STATUSES = new Set<String>{
		'Customer Contacted', 
		'Converted', 
		'Closed' 
	};

	public static final Set<String> SET_OF_TEMPLATES_NAMES = new Set<String>{
		'License Expiry HTML', 
		'Insurance Expiry HTML', 
		'Certification Expiry HTML' 
	};

	public static final String NOTIFICATION_TEMPLATE = 'Trade Ally Referral Notification';

	public static final String NAMESPACE = '';


	public static final Integer COUNT_OF_GROUPS = 3;

	public static final String ORGANIZATION_TEST_NAME = 'TEST ORG';

	public static final String FIRST_GROUP_NAME = 'Tier 1 Trade Allies';

	public static final String FIRST_GROUP_TEST_NAME = 'Tier 1 TesT Trade Allies';

	public static final String SECOND_GROUP_NAME = 'Announcements';

	public static final String THIRD_GROUP_NAME = 'Q&A';

	public static final String COLLABORATION_GROUP_PRIVATE_TYPE = 'Private';

	public static final String COLLABORATION_GROUP_PUBLIC_TYPE = 'Public';
	
	//--- Alerts constants start  ---//
	public static final String ALERTS_INCURANCE_EMAIL = 'Alerts Insurance Email';

	public static final String ALERTS_LICENSE_EMAIL = 'Alerts License Email';

	public static final String ALERTS_CERTIFICATION_EMAIL = 'Alerts Certification Email';

	public static final String ALERTS_INCURANCE_SHOW = 'Alerts Insurance Show';

	public static final String ALERTS_LICENSE_SHOW = 'Alerts License Show';

	public static final String ALERTS_CERTIFICATION_SHOW = 'Alerts Certification Show';
    
    public static final String EMAIL_SENDER_DISPLAY_NAME = 'Email Sender Display name';

	public static final String ALERT_TYPE = 'Alert';
	
	public static final String IN_PROGRESS_STATUS = 'In Progress';

	public static final String ACTIVE_STATUS = 'Active';

	public static final String NOT_STARTED_STATUS = 'Not Started';

	public static final String DEFERRED_STATUS = 'Deferred';

	public static final Set<Integer> DEFAULT_ALERTS_DAYS = new Set<Integer>{2,10,30,45};
	//--- Alerts constants end ---//

	public static final String NUMBER_OF_CUSTOMER_REFERENCES = 'Number of Customer References';

	public static final String NUMBER_OF_TRADE_REFERENCES = 'Number of Trade References';

	public static final String NUMBER_OF_TAX_DOCS = 'Number of Tax Documents';

	public static final String NUMBER_OF_OTHER_DOCS = 'Number of Other Documents';

	public static final String NUMBER_OF_CERTIFICATIONS = 'Number of Certifications';

	public static final String NUMBER_OF_LICENSES = 'Number of Licenses';

	public static final String NUMBER_OF_INSURANCES = 'Number of Insurances';
    
    public static final String HIDE_TABS = 'Hide Tabs';

	public static final String ALERTS_SCHEDULER_NAME = 'AlertsReviewScheduler';

	public static final String STRIPE_INVOICES_SCHEDULER_NAME = 'StripeInvoicesScheduler';

	public static final String EMAIL_OPT_OUT_POLICY = 'FILTER';

	public static final String OBJECT_APPLICATION = 'Application__c';

	public static final String TRADE_ALLY = 'Account';

	public static final String TRADE_ALLY_USER = 'Contact';
	
	public static final String SPECIALITY = 'Specialty__c';
	public static final String TRADE_ALLY_SPECIALITY = 'Trade_Ally_Specialty__c';
	public static final String SPECIALITY_SPECIAL_FIELD = 'Specialty__c';
	public static final String SPECIALITY_SPECIAL_LABEL = 'Participating Programs';
	
	public static final String TERRITORY = 'Territory__c';
	public static final String TERRITORY_ASSIGNMENT = 'Territory_Assignment__c';
	public static final String TERRITORY_SPECIAL_FIELD = 'Territory__c';
	public static final String TERRITORY_SPECIAL_LABEL = 'Participating Locations';

	public static final Map<String,String> MAP_OF_FIRST_SPECIAL_FIELDS = new Map<String,String>{
		'Trade_Ally_Specialty__c' => NAMESPACE + 'Trade_Ally__c',
		'Territory_Assignment__c' => NAMESPACE + 'Trade_Ally__c'
	};
	public static final Map<String,String> MAP_OF_SECOND_SPECIAL_FIELDS = new Map<String,String>{
		'Trade_Ally_Specialty__c' => NAMESPACE + SPECIALITY_SPECIAL_FIELD,
		'Territory_Assignment__c' => NAMESPACE + TERRITORY_SPECIAL_FIELD
	};

	public static final String TAX = 'Tax__c';

	public static final String OTHER = 'Other_Document__c';

	public static final String TRADE_ALLY_REFERENCE = 'Trade_Ally_Reference__c';

	public static final String INCURANCE = 'Insurance__c';

	public static final String LICENSE = 'License__c';

	public static final String REFERRAL = 'Referral__c';
	// Referral filters
	public static final String REFERRAL_FILTER_ALL = 'All';
	public static final String REFERRAL_FILTER_RV = 'Recently Viewed';
	public static final String REFERRAL_FILTER_ER = 'Expired Referrals';
	public static final String REFERRAL_FILTER_CAR = 'Created & Assigned Referrals';
	public static final String REFERRAL_FILTER_CCR = 'Customer Contacted Referrals';
	public static final String REFERRAL_FILTER_CR = 'Converted Referrals';
	//-----------------

	public static final String CERTIFICATION = 'Certification__c';

	public static final String TASK_OBJECT = 'Task';

	public static final String TRADE_ALLY_INCURANCE = 'Trade_Ally_Insurance__c';

	public static final String TRADE_ALLY_LICENSE = 'Trade_Ally_License__c';

	public static final String TRADE_ALLY_CERTIFICATION = 'Trade_Ally_Certification__c';

	public static final String PRIMARY_CONTACT_IMAGE = 'Primary Contact Image';

	public static final Set<String> SET_OF_UNIQUE_ATTACHMENTS = new Set<String>{
		PRIMARY_CONTACT_IMAGE
	};

	public static final String CUSTOMER_REFERENCE = 'Customer Reference';

	public static final String TRADE_REFERENCE = 'Trade Reference';

	public static final String INACTIVE_STATUS = 'Inactive';
	
	public static final String PENDING_STATUS = 'Pending';

	public static final String SUBMIT_APPLICATION_FOR_APPROVAL_SETTINGS = 'Submit Application For Approval';

	public static final String USER_LIMIT_EXCEPTION_MESSAGE = 'The maximum number of users are reached over.';

	public static final String ATT_TEXT = '/servlet/servlet.FileDownload?file=';

	public static final String REGISTRATION_ERROR_MESSAGE = 'Registration Error in site Trade_Ally';

	public static final String USER_EXISTS_ERROR_MESSAGE = 'The user already exists. Please try to use another email address.';

	public static final String NO_REGISTRATION_CODE_MATCHES_ERROR = 'There is not a registration code that matches the value you entered';

	public static final String TRADE_ALLY_WAS_REMOVED_ERROR_MESSAGE = 'The specified Trade Ally was removed';

	public static String USER_LIMIT_TASK_COMMENT = 'New Trade Ally Contact failed. Max Number of users reached';
    
    public static String MISSED_TERMS_CONDITIONS_ERROR = 'You must accept the Terms and Conditions to continue registration.';
    
    public static String MISSED_FIRST_NAME_ERROR = 'First Name is required.';
    
    public static String MISSED_REG_CODE_ERROR = 'Registration Code is required.';

	public static String MISSED_COMPANY_NAME_ERROR = 'Company Name is required.';

	public static String MISSED_COMPANY_CITY_ERROR = 'Company City is required.';

	public static String MISSED_COMPANY_STATE_ERROR = 'Company State is required.';
    
    public static String MISSED_BUSINESS_TYPE_ERROR = 'Application Type is required.';

	public static String MISSED_COMPANY_PHONE_NUMBER_ERROR = 'Company Phone Number is required.';

	public static String DEFAULT_TRADE_ALLY_OWNER_CUSTOM_SETTINGS = 'Default Trade Ally Owner Username';

	public static String TRADE_ALLY_RECORD_TYPE_NAME = 'Trade Ally';

	public static final String TRADE_ALLY_SHARING_ACCESS_LEVEL = 'Edit';

	public static final String RELATED_OPPORTUNITY_SHARING_ACCESS_LEVEL = 'Read';

	public static final String REGISTRATION_CODE_PREFIX = 'REG-';

	public static final String REGISTRATION_CODE_INCORRECT = 'Registration Code Incorrect';

	public static final Integer REGISTRATION_CODE_STARTING_NUMBER = 100;

	public static final Integer LENGTH_OF_REGISTRATION_CODE = 6;

	public static final Integer EXTERNAL_ID_STARTING_NUMBER = 999999;

	public static final String RELATED_TRADE_ALLIES_IDS_KEY = 'relatedTradeAlliesIdsSet';

	public static final String RELATED_TRADE_ALLIES_PARENT_IDS_KEY = 'relatedTradeAlliesParentIdsSet';

	public static final String TIER_ONE_CHATTER_GROUP_NAME = 'Tier 1 Trade Allies';

	public static final String SUBSCRIBED_PROFILE_NAME = 'Subscribed Profile Name';
    
    public static final String RESTRICTED_PROFILE_NAME = 'Custom Community Basic Profile'; //For sub users created using the registration code

}