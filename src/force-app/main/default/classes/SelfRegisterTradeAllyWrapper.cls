public class SelfRegisterTradeAllyWrapper {

	@AuraEnabled
	public String firstname;

	@AuraEnabled
	public String lastname;

	@AuraEnabled
	public String email;

	//The name for the Trade Ally
	@AuraEnabled
	public String companyName;

	//City for the Trade Ally
	@AuraEnabled
	public String companyCity;

	//State for the Trade Ally
	@AuraEnabled
	public String companyState;
    
    //Business Type for the Trade Ally
	@AuraEnabled
	public String companyType;

	//Phone Number for Trade Ally
	@AuraEnabled
	public String companyPhoneNumber;

	@AuraEnabled
	public String password;

	@AuraEnabled
	public String confirmPassword;

	@AuraEnabled
	public String accountId;

	@AuraEnabled
	public String regConfirmUrl;

	@AuraEnabled
	public String extraFields;

	@AuraEnabled
	public String startUrl;

	@AuraEnabled
	public Boolean includePassword;

	@AuraEnabled
	public String registrationCode;

	@AuraEnabled
	public List<Account> tradeAlliesDuplicateList;
    
    @AuraEnabled
	public Boolean includeApplicationType;

	public SelfRegisterTradeAllyWrapper(String firstname, String lastname, String companyName, String companyCity, String companyState, String companyType, String companyPhoneNumber, String email, String password, String confirmPassword, String accountId, String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword, String registrationCode, List<Account> tradeAlliesDuplicateList, Boolean includeApplicationType) {
		this.firstname = firstname;
		this.lastname = lastname;
		this.companyName = companyName;
		this.companyCity = companyCity;
		this.companyState = companyState;
        this.companyType = companyType;
		this.companyPhoneNumber = companyPhoneNumber;
		this.email = email;
		this.password = password;
		this.confirmPassword = confirmPassword;
		this.accountId = accountId;
		this.regConfirmUrl = regConfirmUrl;
		this.extraFields = extraFields;
		this.startUrl = startUrl;
		this.includePassword = includePassword;
		this.registrationCode = registrationCode;
		this.tradeAlliesDuplicateList = tradeAlliesDuplicateList;
        this.includeApplicationType = includeApplicationType;
	}
}