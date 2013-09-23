/************************************************************************************
* Name          :    OpportunityProductSummaryClass
* Description   :    to display custom opportunitySummany related list
* Author        :    Sagar

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Sagar         Created    08/6/2013
******************************************************************************************/
public class OpportunityProductSummaryClass{
    
    public String projectId{get;set;}
    public Integer totalSize{get;set;}
    public Integer remainder{get;set;}
    public boolean loadMore{get;set;}
    
    public OpportunityProductSummaryClass(ApexPages.StandardController controller){
        remainder = 0;      
        loadMore = false;
        //gets the record Id of the account record.
        projectId = (String)controller.getRecord().Id;
    }
    
    /**
     *Return Type: getRelatedOpportunities
     *Return Type: List<Opportunity>
     *Purpose: This method used to get the first 10 opportunities related to an account record.
     *It is also used to rerender the list when the user clicks on link Show (n) more >> in UI.
     **/ 
    public List<Opportunity> getRelatedOpportunities(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        try{
          //query all the opportunity records matching for the account record.
          oppList = [SELECT Name, Account.Name, Owner.Name, Owner.Phone, Owner.Email, Owner.Division__c, Project__r.Name, Type, StageName, CloseDate FROM Opportunity  
                     where Project__c =: projectId order by StageName];                                                        
          //if load more link is clicked then additional opportunity records will be displayed
          if(!loadMore){
              if(oppList.size() > 0){
                totalSize = oppList.size();
                Integer counter = 0;
                //initially only 10 records will be displayed
                if(totalSize >= 10){
                   counter = 10;
                }else{
                   counter = totalSize;
                }
                //if there are more than records to be displayed, initally only 10 records would be displayed.
                for(Integer i = 0; i < counter; i++){
                  opportunityList.add(oppList.get(i));
                }
                if(totalSize > 10){
                  remainder = totalSize - 10;       
                }
              }                 
          }else{
              remainder = 0;
              opportunityList = oppList;
          }
        }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage());
            ApexPages.addMessage(msg);
        }                    
        return opportunityList;        
    }
    
    /**
     *Return Type: loadMoreOpportunities
     *Return Type: void
     *Purpose: This method is called from the visual force page to load more opportunities related to an account record.     
     **/
    public void loadMoreOpportunities(){
       getRelatedOpportunities();
    }
    
    /**
     *Return Type: loadOpportunitiesList
     *Return Type: void
     *Purpose: This method is called from the visual force page to load all opportunities related to an account record.     
     **/
    public void loadOpportunitiesList(){
       getOpportunityList();
    }
    
    /**
     *Return Type: getOpportunityList
     *Return Type: List<Opportunity>
     *Purpose: This method used to get all the opportunities related to an account record.     
     **/ 
    public List<Opportunity> getOpportunityList(){       
        List<Opportunity> oppList = new List<Opportunity>();
        try{
          //null check for account Id
          if(Apexpages.currentpage().getparameters().get('id') != null){
             projectId = Apexpages.currentpage().getparameters().get('id');
             oppList = [SELECT Name, Account.Name, Owner.Name, Owner.Phone, Owner.Email, Owner.Division__c, Project__r.Name, Type, StageName, CloseDate FROM Opportunity  
                     where Project__c =: projectId order by StageName];                                                                                
          }
          /*if(oppList.size() <= 0){
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'No records found.');
              ApexPages.addMessage(msg);
          }*/
        }catch(Exception e){
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, e.getMessage());
            ApexPages.addMessage(msg);
        }                 
        return oppList;        
    }    
}