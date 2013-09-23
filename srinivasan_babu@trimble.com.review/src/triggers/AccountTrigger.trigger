/*****************************************************************************************
    Name    : AccountTrigger 
    Desc    : Auto Trigger the approval process when the user creates new Account and the record Type = 'Account (Pending) Record Type'
              AND
              When the user selects/Enter the Country populate the Region
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       5/21/2013          Created
******************************************************************************************/

trigger AccountTrigger on Account (after insert, after update, before insert, before update) {
    Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(Account.SObjectType);
    /*List<Region_Owner_Mapping__c> regionOwnerList = new List<Region_Owner_Mapping__c>();
    Map<String, Id> regionOwnerMap = new Map<String, Id>();*/ 
    if(Trigger.isBefore){
    	/*if(Trigger.isInsert){
      	   regionOwnerList = [Select Id, Account_Owner__c, Region__c from Region_Owner_Mapping__c]; 	
      	   for(Region_Owner_Mapping__c regionOwner : regionOwnerList){
      	   	  regionOwnerMap.put(regionOwner.Region__c, regionOwner.Account_Owner__c);
      	   }
        }*/
    	
      //validation for account records, if Country is not properly matched with Country Region Mapping custom setting, then it will throw error.    
      for (Account acc : trigger.new){
        try{
             if(acc.BillingCountry != null){    
               String Country = acc.BillingCountry;
               Country_Region_Mapping__c countryMap = Country_Region_Mapping__c.getInstance(Country);
               Geospatial_Country_Region_Mapping__c geoCountryMap = Geospatial_Country_Region_Mapping__c.getInstance(Country);
               
               if(countryMap != null){
                 acc.Region__c = countryMap.Region__c;
                 if(geoCountryMap != null){
                    acc.Geospatial_Region__c = geoCountryMap.Region__c;	
                 }else{
                    acc.addError('Please enter the correct Country name');
                 }
                 
                 /*if(Trigger.isInsert && acc.RecordTypeId == recordTypeMap.get(Label.Account_Pending_Record_Type)){
                 	if(regionOwnerMap.containsKey(acc.Region__c)){
      				   acc.OwnerId = regionOwnerMap.get(acc.Region__c);
                 	}   
      			 }*/
               }else{
                 acc.addError('Please enter the correct Country name');
               }
             }
        }catch(Exception e){
            acc.addError(e.getMessage());
        }      
      }
      
      /*
       * REQ-00202
       * Account Pending record type to be updated to Account Association Record Type.          
       */
      if(Trigger.isUpdate){
         /*List<AccountTeamMember> teamMemberList = new List<AccountTeamMember>();
         Set<String> userIdSet = new Set<String>();
         teamMemberList = [Select Id, UserId, TeamMemberRole, AccountId From AccountTeamMember where AccountId =: Trigger.newMap.keySet() and TeamMemberRole =: Label.ForecastOwner order by CreatedDate];
         Integer count = 1;
         for(AccountTeamMember team : teamMemberList){
            userIdSet.add(team.UserId);
         }
         Map<Id, User> userMap = new Map<Id, User>([Select Id, Name from User where Id IN: userIdSet]);*/
         for(Account account : Trigger.new){
           try{
               //get the old account image to compare values with new record instance                
               Account oldAccount = System.Trigger.oldMap.get(account.Id);                                  
               if(account.Requested_Account_Record_Type__c == 'Association' && oldAccount.Requested_Account_Record_Type__c == 'Association' && 
                 oldAccount.Account_Status__c != 'Active' && account.Account_Status__c == 'Active'){
                 account.RecordTypeId = recordTypeMap.get(Label.Account_Association_Record_Type);
               }
               /*for(AccountTeamMember teamMember : teamMemberList){                                                                  
                 if(teamMember.AccountId == account.Id && count == 1){
                    count = count + 1; 
                    if(userMap.containsKey(teamMember.UserId)){    
                       account.Account_Forecast_Owner__c = userMap.get(teamMember.UserId).Name; 
                    }  
                 }                                
               }
               count = 1;*/
           }catch(Exception e){
               account.addError(e.getMessage());               
           }     
         }
      }        
    }

    if(Trigger.isAfter && Trigger.isInsert){
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        List<ProcessInstance> processInstances = new List<ProcessInstance>();
        try{
            processInstances = [select Id, Status, TargetObjectId from ProcessInstance where  Status = 'Pending' and TargetObjectId IN : Trigger.newMap.keySet()];
            Set<String> targetObjectSet = new Set<String>();
            for(ProcessInstance instance : processInstances){
               targetObjectSet.add(instance.TargetObjectId);
            }
            for (Account acc : trigger.new){
               if (trigger.isAfter && Trigger.isInsert && acc.RecordTypeId == recordTypeMap.get(Label.Account_Pending_Record_Type) && acc.Account_Status__c =='Pending' && !targetObjectSet.contains(acc.Id)){
                 // create the new approval request to submit
                 Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                 req.setComments('Submitted for approval. Please approve.');
                 req.setObjectId(acc.ID);
                 requests.add(req);
               }
            }
            // submit the approval request for processing
            Approval.ProcessResult[] result = Approval.process(requests);
        }catch(Exception e){
            System.debug(e.getMessage());
        }   
    }       
            
    //to update the currency code for forecast year , forecaset quarter and forecast week based on Account
    if(Trigger.isAfter && Trigger.isUpdate){
        try{
 
            List<Forecast_Year__c> fyearListUpdate = new List<Forecast_Year__c>();
            List<Forecast_Year__c> fyearList = new List<Forecast_Year__c>();
            fyearList = [Select id,Account__c,CurrencyIsoCode from Forecast_Year__c where Account__c IN: Trigger.newMap.keySet()];
            Set<ID> fyID = new Set<ID>();
            for (Forecast_Year__c fy :fyearList ){
                fyID.add(fy.id);
            }
            system.debug('fyID' + fyID);
            
            //iterate over the new records to update the CurrencyIsocode of the record with that of related account record
            if(fyearList.size()>0){
                for(Account gAccountList :trigger.new ){
                    for(Forecast_Year__c fyUpdate :fyearList){
                        fyUpdate.CurrencyIsoCode = gAccountList.CurrencyIsoCode;
                        fyearListUpdate.add(fyUpdate);
                    }
                }
                //to prevent triggers to run recursively
                RecursiveTriggerUtility.isTriggerExecute = false;
                update fyearListUpdate;
                RecursiveTriggerUtility.isTriggerExecute = true;
           }
           
           List<Forecast_Qua__c> fquarterListUpdate = new List<Forecast_Qua__c>(); 
           List<Forecast_Qua__c> fquarterList = new List<Forecast_Qua__c>();
           
           //query forecast quarter record related to the forecast year
           fquarterList = [Select id,Forecast_Year__c,CurrencyIsoCode from Forecast_Qua__c where Forecast_Year__c IN:fyID];
           Set<ID> fqID = new set<ID>();
           for(Forecast_Qua__c fq : fquarterList){
                fqID.add(fq.id);
           }
           
           //iterate over the new records to update the CurrencyIsocode of the record with that of related account record
           if(fquarterList.size()>0){
              for(Account gAccountList :trigger.new ){
                for(Forecast_Qua__c fqUpdate :fquarterList){
                    fqUpdate.CurrencyIsoCode = gAccountList.CurrencyIsoCode;
                    fquarterListUpdate.add(fqUpdate);
                }
              }
              //to prevent triggers to run recursively
              RecursiveTriggerUtility.isTriggerExecute = false;
              update fquarterListUpdate;
              RecursiveTriggerUtility.isTriggerExecute = true;
           }
           
           List<Forecast_Week__c> fWeekListUpdate = new List<Forecast_Week__c>();
           List<Forecast_Week__c> fWeekList = new List<Forecast_Week__c>();
           
           fWeekList = [Select id, Forecast_Quarter__c,CurrencyIsoCode from Forecast_Week__c where Forecast_Quarter__c IN :fqID];
           Set<ID> fwID = new set<ID>();
           for(Forecast_Week__c fw : fWeekList){
              fwID.add(fw.id);
           }
           system.debug('fwID' + fwID);
           //iterate over the new records to update the CurrencyIsocode of the record with that of related account record
           if(fWeekList.size()>0){
              for(Account gAccountList : trigger.new){
                  for(Forecast_Week__c fwUpdate :fWeekList){
                     fwUpdate.CurrencyIsoCode = gAccountList.CurrencyIsoCode;
                     fWeekListUpdate.add(fwUpdate);
                  }
              }
              update fWeekListUpdate;
           }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }                
}