/*****************************************************************************************
    Name    : ForecastControllerTestClass 
    Desc    : Used for test coverage of the code implemented in ForecastController class. 
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       5/27/2013          Created
******************************************************************************************/
@isTest
public class ForecastControllerTestClass {
	
	/**
     * Method name  : testForecast
     * Description  : This method covers the positive scenarios of ForecastController
     * Return Type  : void
     * Parameter    : None
     **/
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
	        Account testAccount = new Account(Name='Test123', Account_Forecast_Owner__c = user.Id, Division__c='Infrastructure; Survey;');
	        
	        insert testAccount; 
	        
	        Forecast_Year__c fyear = new Forecast_Year__c();
	        fyear.Account__c = testAccount.Id;
	        fyear.Name_Format__c = 'Week';
	        fyear.Year__c = '2013';
	        fyear.CurrencyIsoCode = 'USD';
	        insert fyear;
	        
	        System.assert(fyear.Account__c == testAccount.Id);
	        
	        Forecast_Qua__c quarter = new Forecast_Qua__c();
	        quarter.FQ__c = 'Q1';
	        //quarter.Name = 'FQ-01';
	        quarter.Forecast_Year__c = fyear.Id; 
	        insert quarter;
	        
	        List<Forecast_Week__c> weekList = new List<Forecast_Week__c>();
	        Forecast_Week__c week;
	        for(Integer i = 1; i <= 13; i++){
	        	week = new Forecast_Week__c();
	        	week.Actual__c = 10;
	        	week.Division__c = 'Infrastructure';
	        	week.Forecast__c = 20; 
	        	week.Forecast_Quarter__c = quarter.Id;
	        	//week.Week__c = 'Week '+i;// not here
	        	week.Week_Index__c = i;
	        	weekList.add(week);	
	        }
	        insert weekList;
			System.assert(weekList.size() == 13);
				        
	        ApexPages.StandardController sc = new ApexPages.StandardController(quarter);
	        PageReference pageRef = Page.ForecastPage;
	        Test.setCurrentPage(pageRef);
	        Apexpages.currentpage().getparameters().put('id', quarter.Id);
	        ForecastController fsc = new ForecastController(sc);        
	        fsc.loadData();
	        fsc.forecastWeek.Division__c = 'Rail';
	        fsc.addRow();
	        fsc.UpdateForecast();
	        
	        fsc.sortDirection = 'DESC';
	        fsc.sortColumns();
	        fsc.setSortDirection('DESC');
	        fsc.getSortDirection();
	        fsc.sortExpression = 'Division__c';
	        
	        fsc.divisionName = 'Infrastructure';
	        fsc.deleteRow();
        }
        Test.stopTest();    
    }
    
    /**
     * Method name  : testMiscellaneous
     * Description  : This method covers the methods of addRow
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testMiscellaneous() { 
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
	        Account testAccount = new Account(Name='Test123', Account_Forecast_Owner__c = user.Id, Division__c='Infrastructure; Survey;');
	        
	        insert testAccount; 
	        
	        Forecast_Year__c fyear = new Forecast_Year__c();
	        fyear.Account__c = testAccount.Id;
	        fyear.Name_Format__c = 'Week';
	        fyear.Year__c = '2013';
	        fyear.CurrencyIsoCode = 'USD';
	        insert fyear;
	        
	        Forecast_Qua__c quarter = new Forecast_Qua__c();
	        quarter.FQ__c = 'Q1';
	        //quarter.Name = 'FQ-01';
	        quarter.Forecast_Year__c = fyear.Id; 
	        insert quarter;
	        
	        List<Forecast_Week__c> weekList = new List<Forecast_Week__c>();
	        Forecast_Week__c week;
	        for(Integer i = 1; i <= 13; i++){
	        	week = new Forecast_Week__c();
	        	week.Actual__c = 10;
	        	week.Division__c = 'Infrastructure';
	        	week.Forecast__c = 20; 
	        	week.Forecast_Quarter__c = quarter.Id;
	        	//week.Week__c = 'Week '+i; not here
	        	week.Week_Index__c = i;
	        	weekList.add(week);	
	        }
	        insert weekList;
	        System.assert(weekList.size() == 13);
	        ApexPages.StandardController sc = new ApexPages.StandardController(quarter);
	        PageReference pageRef = Page.ForecastPage;
	        Test.setCurrentPage(pageRef);
	        Apexpages.currentpage().getparameters().put('id', quarter.Id);
	        ForecastController fsc = new ForecastController(sc);        
	        fsc.loadData();
	        fsc.addRow();
	        fsc.forecastWeek.Division__c = 'Infrastructure';
	        fsc.addRow();
        }
        Test.stopTest();
    }     	
    
    /**
     * Method name  : testForeCastMethod
     * Description  : This method covers the methods of closePopup and showpopup
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testForeCastMethod() { 
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
	        Account testAccount = new Account(Name='Test123', Account_Forecast_Owner__c = user.Id, Division__c='Infrastructure; Survey;');
	        
	        insert testAccount; 
	        
	        Forecast_Year__c fyear = new Forecast_Year__c();
	        fyear.Account__c = testAccount.Id;
	        fyear.Name_Format__c = 'Week';
	        fyear.Year__c = '2013';
	        fyear.CurrencyIsoCode = 'USD';
	        insert fyear;
	        
	        Forecast_Qua__c quarter = new Forecast_Qua__c();
	        quarter.FQ__c = 'Q1';
	        quarter.Forecast_Year__c = fyear.Id; 
	        insert quarter;
	        
	        List<Forecast_Week__c> weekList = new List<Forecast_Week__c>();
	        Forecast_Week__c week;
	        for(Integer i = 1; i <= 13; i++){
	        	week = new Forecast_Week__c();
	        	week.Actual__c = 10;
	        	week.Division__c = 'Infrastructure';
	        	week.Forecast__c = 20; 
	        	week.Forecast_Quarter__c = quarter.Id;
	        	//week.Week__c = 'Week '+i; not here
	        	week.Week_Index__c = i;
	        	weekList.add(week);	
	        }
	        insert weekList;
	        System.assert(weekList.size() == 13);
	        ApexPages.StandardController sc = new ApexPages.StandardController(quarter);
	        PageReference pageRef = Page.ForecastPage;
	        Test.setCurrentPage(pageRef);
	        Apexpages.currentpage().getparameters().put('id', quarter.Id);
	        ForecastController fsc = new ForecastController(sc); 
	        fsc.closePopup();
    		fsc.showPopup();       
        }
        Test.stopTest();
    }
    
    /**
     * Method name  : testForecastAlert
     * Description  : This method covers the methods of ForecastAlert
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testForecastAlert() { 
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
        	Account testAccount = new Account(Name='Test123', Account_Forecast_Owner__c = user.Id, Division__c='Infrastructure');
	        
	        insert testAccount; 
	        
	        Forecast_Year__c fyear = new Forecast_Year__c();
	        fyear.Account__c = testAccount.Id;
	        fyear.Name_Format__c = 'Week';
	        fyear.Year__c = '2013';
	        fyear.CurrencyIsoCode = 'USD';
	        insert fyear;
	        
	        Forecast_Qua__c quarter = new Forecast_Qua__c();
	        quarter.FQ__c = 'Q2';
	        //quarter.Name = 'FQ-01';
	        quarter.Forecast_Year__c = fyear.Id; 
	        insert quarter;
	        
	        List<Forecast_Week__c> weekList = new List<Forecast_Week__c>();
	        Forecast_Week__c week;
	        for(Integer i = 1; i <= 13; i++){
	        	week = new Forecast_Week__c();
	        	week.Actual__c = 10;
	        	week.Division__c = 'Infrastructure';
	        	week.Forecast__c = 20; 
	        	week.Forecast_Quarter__c = quarter.Id;
	        	//week.Week__c = 'Week '+i; not here
	        	week.Week_Index__c = i;
	        	weekList.add(week);	
	        }
	        insert weekList;
	        System.assert(weekList.size() == 13);
	        
        	PageReference pageRef = Page.AccountOverride;
	        Test.setCurrentPage(pageRef);
	        Apexpages.currentpage().getparameters().put('id', testAccount.Id);
	        ForecastController fsc = new ForecastController();
    		fsc.ForecastAlert();
    		fsc.closePopup();
    		fsc.showPopup();
        }
    }
    
    /**
     * Method name  : testAddRow14
     * Description  : This method covers the methods of addRow
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testAddRow14() { 
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
	        Account testAccount = new Account(Name='Test123', Account_Forecast_Owner__c = user.Id, Division__c='Infrastructure; Survey;');
	        
	        insert testAccount; 
	        
	        Forecast_Year__c fyear = new Forecast_Year__c();
	        fyear.Account__c = testAccount.Id;
	        fyear.Name_Format__c = 'Week';
	        fyear.Year__c = '2013';
	        fyear.CurrencyIsoCode = 'USD';
	        insert fyear;
	        
	        Forecast_Qua__c quarter = new Forecast_Qua__c();
	        quarter.FQ__c = 'Q4';
	        quarter.Forecast_Year__c = fyear.Id; 
	        insert quarter;
	        
	        List<Forecast_Week__c> weekList = new List<Forecast_Week__c>();
	        Forecast_Week__c week;
	        for(Integer i = 1; i <= 13; i++){
	        	week = new Forecast_Week__c();
	        	week.Actual__c = 10;
	        	week.Division__c = 'Infrastructure';
	        	week.Forecast__c = 20; 
	        	week.Forecast_Quarter__c = quarter.Id;
	        	week.Week_Index__c = i;
	        	weekList.add(week);	
	        }
	        insert weekList;
	        System.assert(weekList.size() == 13);
	        ApexPages.StandardController sc = new ApexPages.StandardController(quarter);
	        PageReference pageRef = Page.ForecastPage;
	        Test.setCurrentPage(pageRef);
	        Apexpages.currentpage().getparameters().put('id', quarter.Id);
	        ForecastController fsc = new ForecastController(sc);        
	        fsc.loadData();
	        fsc.addRow();
	        fsc.forecastWeek.Division__c = 'Infrastructure';
	        fsc.addRow();
        }
        Test.stopTest();
    }
    
    /**
     * Method name  : testNegativeScenarios
     * Description  : This method covers the testNegativeScenarios
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testNegativeScenarios() { 
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
	        Account testAccount = new Account(Name='Test123', Account_Forecast_Owner__c = user.Id, Division__c='Infrastructure; Survey;');
	        
	        insert testAccount; 
	        
	        Forecast_Year__c fyear = new Forecast_Year__c();
	        fyear.Account__c = testAccount.Id;
	        fyear.Name_Format__c = 'Week';
	        fyear.Year__c = '2013';
	        fyear.CurrencyIsoCode = 'USD';
	        insert fyear;
	        
	        Forecast_Qua__c quarter = new Forecast_Qua__c();
	        quarter.FQ__c = 'Q4';
	        quarter.Forecast_Year__c = fyear.Id; 
	        insert quarter;
	        
	        List<Forecast_Week__c> weekList = new List<Forecast_Week__c>();
	        Forecast_Week__c week;
	        for(Integer i = 1; i <= 10; i++){
	        	week = new Forecast_Week__c();
	        	week.Actual__c = 10;
	        	week.Division__c = 'Infrastructure';
	        	week.Forecast__c = 20; 
	        	week.Forecast_Quarter__c = quarter.Id;
	        	week.Week_Index__c = i;
	        	weekList.add(week);	
	        }
	        insert weekList;
	        System.assert(weekList.size() == 10);
	        ApexPages.StandardController sc = new ApexPages.StandardController(quarter);
	        PageReference pageRef = Page.ForecastPage;
	        Test.setCurrentPage(pageRef);
	        Apexpages.currentpage().getparameters().put('id', null);
	        ForecastController fsc = new ForecastController(sc);        
	        //fsc.loadData();
	        //fsc.addRow();
	        //fsc.forecastWeek.Division__c = 'Infrastructure';
	        //fsc.addRow();
        }
        Test.stopTest();
    }
}