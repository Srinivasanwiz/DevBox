/************************************************************************************
* Name          :    AccountTriggerTestClass
* Description   :    
* Author        :    Sagar

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Sagar                  Created
******************************************************************************************/
@isTest
public class AccountTriggerTestClass {
	
	/**
     * Method name  : testAfterMethod
     * Description  : This method covers the positive scenarios of account trigger
     * Return Type  : void
     * Parameter    : None
     **/
	static testMethod void testAfterMethod() {
		Test.startTest();
        
        Profile profile = [select Id from Profile where Name =: 'System Administrator'];        
        
        User user = new User();
        user.Username = 'sagamehta123@deloitte.com';
        user.Email = 'sagamehta@deloitte.com';
        user.LastName = 'Test';
        user.Alias = 'Test123';
        user.ProfileID = profile.Id;
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.Country = 'United States';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        insert user;
        
        System.runAs(user) {
        
	        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Account');
	        Account a = (Account)targetType.newSObject();
	        
	        Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(a.getSobjectType());
	        
	        Country_Region_Mapping__c countryMap = new Country_Region_Mapping__c();
	        countryMap.Name = 'ABC';
	        countryMap.Region__c = 'XYZ';
	        insert countryMap; 
	        
	        Geospatial_Country_Region_Mapping__c geoCountryMap = new Geospatial_Country_Region_Mapping__c();
	        geoCountryMap.Name = 'ABC';
	        geoCountryMap.Region__c = 'XYZ';
	        insert geoCountryMap;
	                       
	        Account account = new Account();
	        account.Name = 'Test Assign Case Account';
	        account.RecordTypeId = recordTypeMap.get(Label.Account_Pending_Record_Type);
	        account.Account_Forecast_Owner__c = user.Id;
	        account.Account_Status__c = 'Pending';
	        account.Requested_Account_Record_Type__c = 'Association';
	        account.BillingCountry = 'ABC';
	        insert account;
	        
	        Forecast_Year__c fy = new Forecast_Year__c();
	        //fy.Name = 'Test Account';
	        fy.Account__c = account.Id;
			insert fy;
			
			System.assert(fy.Account__c == account.Id);
			
			Forecast_Qua__c qua = new Forecast_Qua__c (); 
			qua.FQ__c = 'Q1';
			qua.Forecast_Year__c = fy.Id;
			insert qua;
			
			System.assert(qua.Forecast_Year__c == fy.Id);
			
			Forecast_Week__c  week = new Forecast_Week__c ();
			week.Forecast_Quarter__c = qua.Id;        
			week.Week_Index__c = 1;
			week.Actual__c = 100;		
			insert week;
			
			System.assert(week.Forecast_Quarter__c == qua.Id);
			
			update account;
			
			System.assert(account.CurrencyIsoCode == fy.CurrencyIsoCode);
			System.assert(account.CurrencyIsoCode == qua.CurrencyIsoCode);
			System.assert(account.CurrencyIsoCode == week.CurrencyIsoCode);
			
	        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
	        req.setComments('Approving request using Trigger');
	        req.setAction('Approve');
	        //req.setNextApproverIds(new Id[] {opp.Next_Approver__c});
	        Id retVal = null;
	
	        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: account.Id]){
	            retVal = workItem.Id;
	        }
	        
	        Id workItemId = retVal;
	        //opp.addError(workItemId);
	        if(workItemId == null){
	            account.addError('Error Occured in Trigger');
	        }else{
	            req.setWorkitemId(workItemId);
	            Approval.ProcessResult result =  Approval.process(req);
	        }
        }    
    	Test.stopTest();
	}
}