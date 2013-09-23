@isTest(SeeAllData = true)
public class DealRegLineItemsTestClass {
	static testMethod void testForecast() { 
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
        user.Country = 'India';
        user.Division__c = 'Infrastructure';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey='UTF-8';
        insert user;
        System.runAs(user) {
	        Deal_Registration__c dealRegistration = new Deal_Registration__c();
			Id recordId = Schema.SObjectType.Deal_Registration__c.getRecordTypeInfosByName().get('Deal Registration Partner').getRecordTypeId();        
	        dealRegistration.RecordTypeId = recordId;
	        dealRegistration.Approval_Status__c = 'Pending Review';
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
	        dealRegistration.OwnerId = user.Id;
	        insert dealRegistration;
	        
	        Product2 product = new Product2();
	        product.IsActive = true;
	        product.Name = 'ABC';
	        product.ProductCode = 'T1';
	        product.Certificate__c = 'C1';
	        insert product;
	        
	        Deal_Registration_Line__c line = new Deal_Registration_Line__c();
	        line.Deal_Registration__c = dealRegistration.Id;
	        line.Product__c = product.Id;
	        line.Quantity__c = 10;
	        //line.Total_Price__c = 100;
	        line.Unit_Price__c  = 10;
	        insert line;
	        
	        PriceBook2 pbe2 = new PriceBook2();
            pbe2.Name = 'Philips Lumileds Pricebook';
            insert pbe2;
            
            Pricebook2 pbook = [select id from Pricebook2 where IsStandard = true limit 1];
            
            /*PricebookEntry pe = new PricebookEntry();
            pe.Pricebook2Id = pbe2.Id;
            pe.UseStandardPrice = false;
            pe.IsActive = true;
            //pe.Pricebook2Id = pbe2.Id;
            pe.Product2Id = product.Id;
            pe.unitprice = 200;
			insert pe;*/
			            
	        PageReference pageRef = Page.DealRegLineItems_PartnerUser;
	        Test.setCurrentPage(pageRef);
	        Apexpages.currentpage().getparameters().put('id', dealRegistration.Id);
	        Apexpages.currentpage().getparameters().put('lineid', line.Id);
	        DealRegLineItems_PartnerUserController puc = new DealRegLineItems_PartnerUserController();
	        puc.cancel();    
	        puc.Save();
	        
        }
        Test.stopTest();    
    }
}