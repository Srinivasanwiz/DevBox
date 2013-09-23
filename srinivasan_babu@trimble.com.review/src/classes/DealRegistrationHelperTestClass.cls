@isTest (seeAllData = true)
public class DealRegistrationHelperTestClass {
	
	static testMethod void testPartOppCreationMethod() {
		Test.startTest();
		Profile profile = [select Id from Profile where Name =: 'System Administrator'];        
        User user = new User();
        user.Username = 'sagamehta123@deloitte.com';
        user.Email = 'sagamehta@deloitte.com';
        user.LastName = 'Test';
        user.Alias = 'Test123';
        user.ProfileID = profile.Id;
        //user.IsPortalEnabled = true;
        //user.PortalRole = 'Manager';
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.Country = 'India';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        insert user;
        
        System.runAs(user) {
        	Country_Region_Mapping__c countryMap = new Country_Region_Mapping__c();
	        countryMap.Name = 'ABC';
	        countryMap.Region__c = 'XYZ';
	        insert countryMap; 
	        
	        Geospatial_Country_Region_Mapping__c geoCountryMap = new Geospatial_Country_Region_Mapping__c();
	        geoCountryMap.Name = 'ABC';
	        geoCountryMap.Region__c = 'XYZ';
	        insert geoCountryMap;
	                
	        Deal_Registration__c dealRegistration = new Deal_Registration__c();
			Id recordId = Schema.SObjectType.Deal_Registration__c.getRecordTypeInfosByName().get('Deal Registration Partner').getRecordTypeId();        
	        dealRegistration.RecordTypeId = recordId;
	        dealRegistration.Approval_Status__c = 'Pending Review';
	        dealRegistration.Approximate_Deal_Amount__c = 10;
	        dealRegistration.City__c = 'Mumbai';
	        dealRegistration.Company__c = 'ABC Corporation';
	        dealRegistration.Competitive_Deal__c = true;
	        dealRegistration.Competitive_Offering__c = '100000';
	        dealRegistration.Country__c = 'ABC';
	        dealRegistration.Deal_Type__c = 'New Business';
	        dealRegistration.Email__c = 'sagamehta@deloitte.com';
	        dealRegistration.First_Name__c = 'Test';
	        dealRegistration.I_confirm_i_have_read_understood_T_C_s__c = true;
	        dealRegistration.Industry__c = 'Agriculture';
	        dealRegistration.Last_Name__c = 'Test';
	        dealRegistration.Sales_Stage__c = '1- Qualification';
	        dealRegistration.Website__c = 'https://login.salesforce.com';
	        dealRegistration.Title__c = 'Test';
	        dealRegistration.Street__c = 'Test Street';
	        dealRegistration.State_Province__c = 'MH';
	        dealRegistration.Role__c = 'Influencer';
	        dealRegistration.Project_Name__c = 'test';
	        dealRegistration.Project_Description__c = 'desc';
	        dealRegistration.Project_Budgeted_Amount__c = 1000000;
	        dealRegistration.Project_Budgeted__c = true;
	        dealRegistration.Primary_Competitor__c = 'competitor';
	        dealRegistration.Phone__c = '9900000';
	        dealRegistration.Estimated_Close_Date__c = Date.newInstance(2013, 12, 12);
	        dealRegistration.OwnerId = user.Id;
	        insert dealRegistration;
	        
	        Deal_Registration__c reg = [Select Id, Estimated_Close_Date__c, RecordTypeId, Approval_Status__c, Approximate_Deal_Amount__c, City__c, Company__c, Competitive_Deal__c,
	        Competitive_Offering__c, Country__c, Deal_Type__c, Email__c, First_Name__c, I_confirm_i_have_read_understood_T_C_s__c, Industry__c, 
	        Last_Name__c, Sales_Stage__c, Website__c, Title__c, Street__c, State_Province__c, Role__c, Project_Name__c, Project_Description__c, 
	        Project_Budgeted_Amount__c, Project_Budgeted__c, Primary_Competitor__c, Phone__c, OwnerId from Deal_Registration__c where Id =: dealRegistration.Id];
	        
	        Map <Id, Deal_Registration__c> mapOldDealRegnew = new Map <Id, Deal_Registration__c>();
	        mapOldDealRegnew.put(reg.Id, reg); 
	        
	        Deal_Registration__c reg1 = [Select Id, RecordTypeId, Estimated_Close_Date__c, Approval_Status__c, Approximate_Deal_Amount__c, City__c, Company__c, Competitive_Deal__c,
	        Competitive_Offering__c, Country__c, Deal_Type__c, Email__c, First_Name__c, I_confirm_i_have_read_understood_T_C_s__c, Industry__c, 
	        Last_Name__c, Sales_Stage__c, Website__c, Title__c, Street__c, State_Province__c, Role__c, Project_Name__c, Project_Description__c, 
	        Project_Budgeted_Amount__c, Project_Budgeted__c, Primary_Competitor__c, Phone__c, OwnerId from Deal_Registration__c where Id =: dealRegistration.Id];
	        
	        Map <Id, Deal_Registration__c> mapDealRegnew = new Map <Id, Deal_Registration__c>();
	        reg1.Approval_Status__c = 'Approved';
	        mapDealRegnew.put(reg1.Id, reg1);
	        
	        PriceBook2 pbe2 = new PriceBook2();
            pbe2.Name = 'Philips Lumileds Pricebook';
            insert pbe2;
            
            /*Pricebook2 pbook = [select id from Pricebook2 where IsStandard = true limit 1];
            
            PricebookEntry pe = new PricebookEntry();
            pe.Pricebook2Id = pbook.Id;
            pe.UseStandardPrice = false;
            pe.IsActive = true;
            //pe.Pricebook2Id = pbe2.Id;
            pe.Product2Id = product.Id;
            pe.unitprice = 200;
			insert pe;*/
	        
	        DealRegistrationHelper.PartOppCreation(mapDealRegnew, mapOldDealRegnew);
	        
	        /*Deal_Registration__c reg = [Select Id, RecordTypeId, Approval_Status__c, Approximate_Deal_Amount__c, City__c, Company__c, Competitive_Deal__c,
	        Competitive_Offering__c, Country__c, Deal_Type__c, Email__c, First_Name__c, I_confirm_i_have_read_understood_T_C_s__c, Industry__c, 
	        Last_Name__c, Sales_Stage__c, Website__c, Title__c, Street__c, State_Province__c, Role__c, Project_Name__c, Project_Description__c, 
	        Project_Budgeted_Amount__c, Project_Budgeted__c, Primary_Competitor__c, Phone__c from Deal_Registration__c where Id =: dealRegistration.Id];
	        reg.Approval_Status__c = 'Approved';
	        update reg;*/
        }    
        Test.stopTest();
	}
	
	static testMethod void testThresholdMetCheck() {
		Test.startTest();
		Profile profile = [select Id from Profile where Name =: 'System Administrator'];        
        User user = new User();
        user.Username = 'sagamehta123@deloitte.com';
        user.Email = 'sagamehta@deloitte.com';
        user.LastName = 'Test';
        user.Alias = 'Test123';
        user.ProfileID = profile.Id;
        //user.IsPortalEnabled = true;
        //user.PortalRole = 'Manager';
        user.LocaleSidKey = 'en_US';
        user.LanguageLocaleKey = 'en_US';
        user.Country = 'India';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        insert user;
        
        System.runAs(user) {
			Deal_Registration__c dealRegistration = new Deal_Registration__c();
			Id recordId = Schema.SObjectType.Deal_Registration__c.getRecordTypeInfosByName().get('Deal Registration Partner').getRecordTypeId();        
	        dealRegistration.RecordTypeId = recordId;
	        dealRegistration.Approval_Status__c = 'Unsubmitted';
	        dealRegistration.Approximate_Deal_Amount__c = 10;
	        dealRegistration.City__c = 'Mumbai';
	        dealRegistration.Company__c = 'ABC Corporation';
	        dealRegistration.Competitive_Deal__c = true;
	        dealRegistration.Competitive_Offering__c = '100000';
	        dealRegistration.Country__c = 'India';
	        dealRegistration.Deal_Type__c = 'New Business';
	        dealRegistration.Email__c = 'sagamehta@deloitte.com';
	        dealRegistration.First_Name__c = 'Test';
	        dealRegistration.I_confirm_i_have_read_understood_T_C_s__c = true;
	        dealRegistration.Industry__c = 'Agriculture';
	        dealRegistration.Last_Name__c = 'Test';
	        dealRegistration.Sales_Stage__c = '1- Qualification';
	        dealRegistration.Website__c = 'https://login.salesforce.com';
	        dealRegistration.Title__c = 'Test';
	        dealRegistration.Street__c = 'Test Street';
	        dealRegistration.State_Province__c = 'MH';
	        dealRegistration.Role__c = 'Influencer';
	        dealRegistration.Project_Name__c = 'test';
	        dealRegistration.Project_Description__c = 'desc';
	        dealRegistration.Project_Budgeted_Amount__c = 1000000;
	        dealRegistration.Project_Budgeted__c = true;
	        dealRegistration.Primary_Competitor__c = 'competitor';
	        dealRegistration.Phone__c = '9900000';
	        insert dealRegistration;
	        
	        DealRegistrationHelper.thresholdMetCheck(dealRegistration.Id, '11');
        }
        Test.stopTest();    
	}
}