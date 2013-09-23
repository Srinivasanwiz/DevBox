/************************************************************************************
* Name          :    AcceptRejectHelperTestClass
* Description   :    
* Author        :    Sagar

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Sagar                  Created
******************************************************************************************/
@isTest
public class AcceptRejectHelperTestClass {
	
	/**
     * Method name  : testAcceptLeadMethod
     * Description  : This method covers the positive and negative scenarios of acceptLead method
     * Return Type  : void
     * Parameter    : None
     **/
	static testMethod void testAcceptLeadMethod() {
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
        Database.insert(user);
        //insert user;
        
        System.runAs(user) { 
	        List<Id> caseIdList = new List<Id>();
	        Lead newLead = new Lead();
	        newLead.LastName = 'Test Lead';
	        newLead.Status = 'Suspect';
	        newLead.Company = 'Company Test';
	        newLead.LeadSource = 'Advertisement';
	        newLead.Country__c = 'ABC';
	        newLead.OwnerId = user.Id;
	        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Lead');
        	Lead l = (Lead)targetType.newSObject();
			Map<String, Id> recordTypeMaps = RecursiveTriggerUtility.loadRecordTypeMap(l.getSobjectType());	        
	        Id recordId = recordTypeMaps.get(Label.Lead_Partner_Portal_Record_Type);
	        //newLead.RecordTypeId = recordId;
	        //newLead.RecordTypeId = recordType.Id; 
	        insert newLead;
			System.assert(newLead.Country__c == 'ABC');
			System.assert(newLead.OwnerId == user.Id);
	    	Id leadId = AcceptRejectHelperClass.acceptLead(newLead.Id);
        }
        Test.stopTest();
    }
	
	/**
     * Method name  : testRejectLead
     * Description  : This method covers the positive and negative scenarios of rejectLead method
     * Return Type  : void
     * Parameter    : None
     **/
	static testMethod void testRejectLead() {
		Test.startTest();
        
        Profile profile2 = [select Id from Profile where Name =: 'System Administrator'];
        User user = new User();
        user.Username = 'sagamehta123@deloitte.com';
        user.Email = 'sagamehta@deloitte.com';
        user.LastName = 'Test';
        user.Alias = 'Test123';
        user.ProfileID = profile2.Id;
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.Country = 'ABC';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        insert user;
        
        System.runAs(user) { 
	        List<Id> caseIdList = new List<Id>();
	        Lead newLead = new Lead();
	        newLead.LastName = 'Test Lead';
	        newLead.Status = 'Suspect';
	        newLead.Company = 'Company Test';
	        newLead.LeadSource = 'Advertisement';
	        newLead.Country__c = 'ABC';
	        newLead.OwnerId = user.Id;
	        newLead.Qualified_By__c = user.Id; 
	        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Lead');
        	Lead l = (Lead)targetType.newSObject();
			Map<String, Id> recordTypeMaps = RecursiveTriggerUtility.loadRecordTypeMap(l.getSobjectType());	
	        Id recordIdcustomer = recordTypeMaps.get(Label.Lead_Partner_Portal_Record_Type);
	        //newLead.RecordTypeId = recordIdcustomer.Id; 
	        insert newLead;
	        System.assert(newLead.Country__c == 'ABC');
			System.assert(newLead.OwnerId == user.Id);
	        AcceptRejectHelperClass.rejectLead(newLead.Id, 'Lead rejected');
        }
        Test.stopTest();
	}

}