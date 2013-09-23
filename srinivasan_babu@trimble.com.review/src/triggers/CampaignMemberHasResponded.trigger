/*****************************************************************************************
    Name    : CampaignMemberHasResponded 
    Desc    : Use to trigger lead assignment rule base on lead status and recordtype criteria.
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       5/27/2013          Created
******************************************************************************************/

trigger CampaignMemberHasResponded on CampaignMember(after insert, after update) {
    if (RecursiveTriggerUtility.isTriggerExecute != true) {
        Map<String, Id> recordTypeMap = RecursiveTriggerUtility.loadRecordTypeMap(Lead.SObjectType);
        List < Lead > Leads = new List < Lead > ();
        List < Id > lIds = new List < id > ();
        Set < Id > cmpMemSet = new Set < Id > ();

        // To get the lead record type id
        ID LeadRecordTypeId = recordTypeMap.get(Label.Lead_Customer_Record_Type);
        ID LeadMarketingRecordTypeId = recordTypeMap.get(Label.Lead_Marketing_Record_Type);
        //To check the campaign member status
        for (CampaignMember cmpMem: Trigger.new) {
            if ((Trigger.isInsert || Trigger.oldMap.get(cmpMem.Id).Status != Label.CampMember_Status_Responded) && cmpMem.HasResponded == true && cmpMem.Status == Label.CampMember_Status_Responded) {
                cmpMemSet.add(cmpMem.LeadId);
            }
        }
        
        //To check if the list have any campaigns  
        if (cmpMemSet.size() > 0)
            for (Lead l: [Select id, Responded__c, Status,RecordTypeId FROM Lead WHERE id IN: cmpMemSet]) {
               if(l.status == Label.Lead_Status_Nurture && l.RecordTypeId == LeadRecordTypeId){
                l.Status = Label.Lead_Status_Inquiry;
                Leads.add(l);
                lIds.add(l.Id);
               }else if (l.RecordTypeId == LeadMarketingRecordTypeId){
                    l.RecordTypeId = LeadRecordTypeId;
                    l.Status = Label.Lead_Status_Inquiry;
                    Leads.add(l);
                    lIds.add(l.Id);
               }
        }
        if (leads.size() > 0)
            RecursiveTriggerUtility.isTriggerExecute = true;
        update leads;
        
        //To trigger lead assignment rule
        if (AssignLeads.assignAlreadyCalled() == FALSE && lIds.size() > 0) {
            AssignLeads.Assign(lIds);
        }
    }
}