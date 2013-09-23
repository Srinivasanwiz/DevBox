/*****************************************************************************************
    Name    : LeadHasResponded 
    Desc    : After update trigger to update leads with Lead (Marketing) Record Type
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       5/21/2013          Created
Ruben Thomas          7/9/2013           Updated 
******************************************************************************************/

trigger LeadHasResponded on Lead (before update, after update, after insert) {
        Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(Lead.SObjectType);
        if(Trigger.isBefore && Trigger.isUpdate && RecursiveTriggerUtility.isTriggerExecute != true){
            List<Group> groupList = new List<Group>();
            groupList = [Select Id from Group where DeveloperName =: Label.Nurture_Lead_Queue]; 
            
            List<Id> leadIsList = new List<id>(); 
            for(Lead lead : trigger.new){
                try{
                    //check if the lead has the status nurture and record type of Customer record type
                    Lead oldLead = System.Trigger.oldMap.get(lead.Id);
                    if (lead.IsConverted == false && oldLead.Status != Label.Lead_Status_Nurture && lead.Status == Label.Lead_Status_Nurture && lead.RecordTypeId == recordTypeMap.get(Label.Lead_Customer_Record_Type)){
                        leadIsList.add(lead.Id);
                    }
                    if(groupList.size() > 0){
                        Group gr = groupList.get(0);
                        if(lead.Status == Label.Lead_Status_Nurture && lead.RecordTypeId == recordTypeMap.get(Label.Lead_Customer_Record_Type) && oldLead.OwnerId == gr.Id){
                            lead.Status = Label.Lead_Status_Inquiry;
                        }
                    }
                }catch(Exception e){
                    lead.addError(e.getMessage());
                }
            }
            if (AssignLeads.assignAlreadyCalled()==FALSE && leadIsList.size()>0){
                RecursiveTriggerUtility.isTriggerExecute =  true;
                //add all the matching Leads to be assigned to a assignment rule in AssignLeads class
                AssignLeads.Assign(leadIsList);
            }
        }
        
        if(Trigger.isAfter && Trigger.isUpdate && RecursiveTriggerUtility.isTriggerExecute != true || (Trigger.isInsert)){
            List<CampaignMember> updateCampaignMemberList = new List<CampaignMember>();
            List<Id> leadIdList = new List<id>();
            List<Id> updatedLeadIdList = new List<id>();
            Set<Id> leadIdSet = new Set<Id>();
           
            List<Lead> updateLeadList  = new List<Lead>();
            //To update Campaign Member with  Status fields     
            List<CampaignMember> campaignMemberList = new List<CampaignMember>();
            for(Lead lead : Trigger.new){
                updatedLeadIdList.add(lead.Id);
            }
            campaignMemberList = [Select CampaignId, HasResponded, LeadId, Status FROM CampaignMember WHERE LeadId IN: updatedLeadIdList];
            for(Lead lead : Trigger.new){
                try{
                    for(CampaignMember cmpMem : campaignMemberList){
                        if(cmpMem.LeadId == lead.Id){ 
                           if(lead.Status == Label.Lead_Status_Inquiry && lead.RecordTypeId == recordTypeMap.get(Label.Lead_Marketing_Record_Type) && cmpMem.Status != Label.CampMember_Status_Responded && cmpMem.LeadId != null){       
                              cmpMem.Status = Label.CampMember_Status_Responded;
                              updateCampaignMemberList.add(cmpMem); 
                              leadIdSet.add(lead.Id);
       						  leadIdList.add(lead.Id);                        	
                           } 
                        }
                    }
              
                    
                    if(updateCampaignMemberList.size()==0 && lead.Status == Label.Lead_Status_Inquiry && lead.RecordTypeId == recordTypeMap.get(Label.Lead_Marketing_Record_Type)){
                        lead.addError('Please associate the lead to a Campaign to pass the record to sales');
                    } 
                
                    /**** Logic added for checking the Status as Nurture on a Lead record creation ***/
                    /*if(Trigger.isInsert){
                       for(Lead le1 : Trigger.new){
                          if(le1.Status == Label.Lead_Status_Nurture){
                            leadIdList.add(le1.Id);
                          }
                       }
                    }*/
                    /**********************/ 
                }catch(Exception e){
                    lead.addError(e.getMessage());
                }   
            }
            //To check the condition lead status and leadrecortype and fill the list leadIdList
            try{    
                if(updateCampaignMemberList.size()>0){
                    update updateCampaignMemberList;
                    
                    if(RecursiveTriggerUtility.isLeadUpdateExecute == false){
                        
                        for(Lead lead : [SELECT Id,Status, RecordTypeId, IsConverted FROM Lead WHERE Id IN: leadIdSet]){
                            //check to validate the old status value to be targeted and new value to be inquiry
                            if((Trigger.oldMap.get(lead.Id).Status == Label.Lead_Status_Targeted) && lead.IsConverted==False && lead.Status == Label.Lead_Status_Inquiry && lead.RecordTypeId == recordTypeMap.get(Label.Lead_Marketing_Record_Type)){
                                lead.Status = Label.Lead_Status_Inquiry; 
                                lead.RecordTypeId = recordTypeMap.get(Label.Lead_Customer_Record_Type);
                                updateLeadList.add(lead);
                                leadIdList.add(lead.Id);
                            }
                        }
                        update(updateLeadList);
                        RecursiveTriggerUtility.isLeadUpdateExecute = true;
                    }
                }
                RecursiveTriggerUtility.isTriggerExecute = true;
                //To call the method to trigger lead assignment rule
                if (AssignLeads.assignAlreadyCalled() == false && leadIdList.size() > 0){
                   AssignLeads.Assign(leadIdList);
                }
            }catch(Exception e){
                System.debug(e.getMessage());
            } 
    }
}