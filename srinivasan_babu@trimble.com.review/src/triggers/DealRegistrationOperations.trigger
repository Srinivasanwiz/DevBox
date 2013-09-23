trigger DealRegistrationOperations on Deal_Registration__c (before update) {
    Set<id> setDealId = new Set<id>();
    //for before update triggers
    if(trigger.isUpdate && trigger.isBefore){
       DealRegistrationHelper.PartOppCreation(trigger.newMap,trigger.oldMap);       
    }
    
    
}