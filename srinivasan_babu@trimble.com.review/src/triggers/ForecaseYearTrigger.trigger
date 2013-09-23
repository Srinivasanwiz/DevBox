/*****************************************************************************************
    Name    : ForecaseYearTrigger 
    Desc    : Trigger to check and alert when user create duplicate year  for the same account and also to update the name format field
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       6/13/2013          Created
******************************************************************************************/

trigger ForecaseYearTrigger on Forecast_Year__c (before insert) {

	List<Forecast_Year__c> forecastYearList = new List<Forecast_Year__c>();
	//before insert trigger
	if(trigger.isbefore & trigger.isInsert){
		Set<Id> accountIdSet = new Set<Id>();
		Set<String> yearSet = new Set<String>();
		Set<String> accountYearSet = new Set<String>();
		List<Account> accList = new List<Account>();
		Map<Id, Account> accountMap = new Map<Id, Account>();
		  
		for(Forecast_Year__c fy : trigger.new){
			accountIdSet.add(fy.Account__c);
			yearSet.add(fy.Year__c);
		}
		
		//query account list to update the CurrencyIsoCode to forecast year
		accList = [Select id, CurrencyIsoCode from Account where ID IN : accountIdSet];
		for(Account account : accList){
			accountMap.put(account.Id, account);
		}
		
		//query forecast year to check if the new forecast year entry already exists
		forecastYearList = [Select Year__c, Account__c, Forecast_Year__c.Account__r.CurrencyIsoCode from Forecast_Year__c where Account__c IN: accountIdSet and Year__c IN: yearSet];
		
		for(Forecast_Year__c forecastYear : forecastYearList){
			accountYearSet.add(forecastYear.Account__c + '-' + forecastYear.Year__c);
		}
		
		//if Year value entered is incorrect. If year already exists for the related account record, then validate with error message
		Set<Id> accIdSet = new Set<Id>();
		accIdSet = accountMap.keySet();
		for(Forecast_Year__c fy : trigger.new){
			//if forecast year already exists, then throw error
			if(accountYearSet.contains(fy.Account__c + '-' + fy.Year__c)){
				fy.adderror('Forecast for the year '+ fy.Year__c + ' already exists');
			}else{
			   fy.Name_Format__c = 'FY-'+fy.Year__c;
			   if(accIdSet.contains(fy.Account__c)){
			   	  //update the currency code with that of the currency code of account record
			   	  fy.CurrencyIsoCode = accountMap.get(fy.Account__c).CurrencyIsoCode;
			   }
			}
		}
	}
}