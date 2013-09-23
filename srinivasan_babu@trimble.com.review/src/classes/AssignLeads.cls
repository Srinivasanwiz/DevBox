/*****************************************************************************************
    Name    : AssignLeads 
    Desc    : Used to assign Leads to the eligible Lead queue 
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       4/27/2013          Created
******************************************************************************************/
global class AssignLeads{

  public static Boolean assignAlreadyCalled=FALSE;

  public static boolean assignAlreadyCalled(){
     return assignAlreadyCalled;
  }
	
  /*
   * Method name  : assign
   * Description  : Method to assign the lead record to Assignment rule
   * Return Type  : Void
   * Parameter    : lIds
   */	
  @future
  public static void assign(List<Id> lIds){
     assignAlreadyCalled=TRUE;
     try{
        //Query the lead records.
	    List<Lead> leads=[SELECT Id FROM Lead WHERE Id IN: lIds];
	    for(lead l : leads){
	       //Assign all lead records to Assignment rule.
	       Database.DMLOptions dmo = new Database.DMLOptions();
	       dmo.assignmentRuleHeader.useDefaultRule= true;
	       l.setOptions(dmo);
	    }
	    update(leads);
     }catch(Exception e){
        System.debug(e.getMessage());
     }
  }
}