/************************************************************************************
* Name          :    OpportunityProductSummaryTestClass
* Description   :    
* Author        :    Sagar

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Sagar                  Created
******************************************************************************************/
@isTest
public class OpportunityProductSummaryTestClass {
  
  /**
     * Method name  : testLoadMoreOpportunities
     * Description  : This method covers the positive and negative scenarios of loadMoreOpportunities method
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testLoadMoreOpportunities() {  
             
        Projectz__c testProject = new Projectz__c(Name='Test123');
        insert testProject;                     
        Opportunity opp;
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i = 0; i < 3; i++){
           opp = new Opportunity();
           opp.Name = 'test+i';
           opp.StageName = '1';
           opp.ForecastCategoryName = 'Pipeline';
           opp.CloseDate = Date.newInstance(2013, 12, 1);
           opp.Project__c = testProject.Id;
           opp.Type = 'New Business';
           oppList.add(opp);
        }
        insert oppList;
        System.assert(oppList.size() == 3);
        ApexPages.StandardController sc = new ApexPages.StandardController(testProject);
        PageReference pageRef = Page.projectOpportunityRelatedCustomPage;
        Test.setCurrentPage(pageRef);
        OpportunityProductSummaryClass osc = new OpportunityProductSummaryClass(sc);        
        osc.loadMoreOpportunities();
        Apexpages.currentpage().getparameters().put('id', testProject.Id); 
        osc.loadOpportunitiesList();
    }
    
    /**
     * Method name  : testNegativeScenarios
     * Description  : This method covers the negative scenarios
     * Return Type  : void
     * Parameter    : None
     **/
    static testMethod void testNegativeScenarios() {  
             
        Projectz__c testProject = new Projectz__c(Name='Test123');
        insert testProject;                                          
        Opportunity opp;
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i = 0; i < 3; i++){
           opp = new Opportunity();
           opp.Name = 'test+i';
           opp.StageName = '1';
           opp.ForecastCategoryName = 'Pipeline';
           opp.CloseDate = Date.newInstance(2013, 12, 1);
           opp.Project__c = testProject.Id;
           opp.Type = 'New Business';
           oppList.add(opp);
        }
        insert oppList;
        System.assert(oppList.size() == 3);
        ApexPages.StandardController sc = new ApexPages.StandardController(testProject);
        PageReference pageRef = Page.projectOpportunityRelatedCustomPage;
        Test.setCurrentPage(pageRef);
        OpportunityProductSummaryClass osc = new OpportunityProductSummaryClass(sc);
        osc.loadMore = null;        
        osc.loadMoreOpportunities();
        Apexpages.currentpage().getparameters().put('id', null); 
        osc.loadOpportunitiesList();
    }
}