/*****************************************************************************************
    Name    : AcceptRejectHelperClass 
    Desc    : Used implementing Accept/Reject Lead functionality for Partner user. When the partner accepts the lead it converts 
    	 	  to Opportunity and if the partner rejects the lead then it reassign the lead back to the original user who assign the Lead
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       4/27/2013          Created
******************************************************************************************/
global with sharing class AcceptRejectHelperClass{
    
    /*
     * Method name  : acceptLead
     * Description  : Method to accept the lead and convert it to Opportunity
     * Return Type  : Void
     * Parameter    : iLead
     */    	
    webservice static ID acceptLead(ID iLead) {
    	Database.LeadConvertResult lcr;
    		
    	try{
	    	Database.LeadConvert lc = new Database.LeadConvert();
	    	Id leadAccountId;
	    	leadAccountId = System.Label.Lead_Conversion_AccountId;
	    	
	    	String convertedStatus;
	    	convertedStatus ='Qualified - Converted';
	    	
	        Lead LeadIns = [select Name,RecordTypeId, ID, OwnerId, Company from Lead where Id = :iLead];
	       
	        //Convert lead record
	        lc.setLeadId(leadIns.Id);
	       
	        Id userId;
	        List<User> userList;
	        String partnerAccName = ''; 
	        userList = [select Id, Contact.Account.Name from User where ID =: LeadIns.OwnerId];
	        for(User us : userList){
	            userId = us.Id;
	            //Populate parnterAccName with name of the selected contact's account
	            partnerAccName = us.Contact.Account.Name;
	            break;
	        }
	        lc.setOwnerId(userId);  
	        //Check if the account used for opportunities converted exists. The Account Id is available in custom setting Lead Conversion AccountId                      
	        List<Account> accList = new List<Account>();
	        Account la = null;
	        accList = [select Id from Account where Id =: leadAccountId];
	        if(accList.size() > 0){
	        	la = accList.get(0);
	        }
	        
	        Account a = new Account();
	        //If the account doesn't exist display error message on the page
	        if(la == null){
	            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The account to be assigned to the Opportunity does not exist'));
	        }else{
	            a = la;
	        }
	              
	         String name = '';
	         if(leadIns.Company != NULL){            
	             //Add company name to the name of the opportunity to be created
	             name+=leadIns.Company+' - ';
	         }
	         //Set the name in the format 'Lead's Company + Lead's Product Interest + Parnter Account Name'
	         lc.setOpportunityName(name + partnerAccName); 
	               
	         //Set the opportunity status
	         lc.setConvertedStatus(convertedStatus);  
	         //Convert the opportunity
	         lcr = Database.convertLead(lc);  
	            
	         //Fetch the new opportunity's Id
	         Id oppId = lcr.getOpportunityId();
	         Opportunity opp = [select Qualified_By__c, Lead_Name_In_Opp__c from Opportunity where Id = :oppId];
	         opp.Qualified_By__c = UserInfo.getUserId();
	         //opp.Product_Interest__c = leadIns.Product_Interest__c;
	         opp.Notify_Lead_Accept__c = true;
	         opp.Lead_Name_In_Opp__c = leadIns.Name;
	         Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(Opportunity.SObjectType);
	         
	         //Check if Opportunity name contains value "Opportunity (Partner) Record Type"      
	         if(recordTypeMap.containsKey(Label.Opportunity_Partner_Record_Type)){
	             opp.RecordTypeId = recordTypeMap.get(Label.Opportunity_Partner_Record_Type);
	         }
	         update opp;
	         
	         // On the Contact, To update  Record Type = Contact (Partner User) Record Type
	         Id ContactID = lcr.getContactId();
	         Contact Cntct  = [Select RecordTypeId from Contact where id = : ContactID];
	         Map<String, Id> recordTypeMaps = RecursiveTriggerUtility.loadRecordTypeMap(Contact.SObjectType);
	         
	         Cntct.RecordTypeId = recordTypeMaps.get(Label.Contact_Partner_User_Record_Type);	         
	         update Cntct;
	         return lcr.getOpportunityId();
    	}catch(Exception e){
    		System.debug(e.getMessage());
    	}
    	return null;        
    }
    
    /*
     * Method name  : rejectLead
     * Description  : Method to Reject the lead and and assign the lead back to the original user.
     * Return Type  : Void
     * Parameter    : LeadID,rejectReason
     */
    webservice static void rejectLead(ID LeadID, String rejectReason) {
     	try{
	     	DateTime Dt = date.today();
	        
	     	String RejectedBy;
	     	List<User> usrName = new List<User>();
	     	Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(Lead.SObjectType);
	     	//Query records as per the lead Id.
	        Lead l = [select Rejection_Reason__c,Rejection_Reason_History__c,Company, Qualified_By__c, OwnerId, RecordTypeId, Notify_Lead_Reject__c from Lead where Id =: LeadID];
	        usrName = [Select Name from User where id =: l.OwnerId];
	        for (user u: usrName){
	        	RejectedBy =  u.name;
	        }
	        
	        l.Rejection_Reason__c = rejectReason;
	        l.OwnerId = l.Qualified_By__c;
	        l.Notify_Lead_Reject__c = true;
	        l.isPartnerReject__c = true;
	        l.RecordTypeId =  recordTypeMap.get(Label.Lead_Customer_Record_Type);
	        
	        //if Rejection history is null, then do not assign the Rejection_History_Reason value
	        if(l.Rejection_Reason_History__c == null){
	        	l.Rejection_Reason_History__c =  RejectedBy +'	||	'+ l.Company + '	||	'+ Dt.format('MM/dd/yyyy') +'	||	'+ rejectReason;
	        }else{
	        	l.Rejection_Reason_History__c = l.Rejection_Reason_History__c + ' \r\n' + RejectedBy +'	||	'+ l.Company +'	||	'+ Dt.format('MM/dd/yyyy') +'	||	'+ rejectReason;
	        }
	 		      
	        update l;
     	}catch(Exception e){
     		System.debug(e.getMessage());
     	}
    }
}