/************************************************************************************
* Name          :    RecursiveTriggerUtility
* Description   :    Global class to use static variables to stop iterative triggers and to load recordType in a map.
* Author        :    Sagar

Modification Log
----------------
Date             Developer                Comments
------------------------------------------------------------------------------------------
                   Sagar         Created	06/10/2013
******************************************************************************************/
global class RecursiveTriggerUtility{
	
 	public static boolean isTriggerExecute;
 	public static boolean isLeadUpdateExecute;
 	public static Map<String, Id> recordTypeMap;
 	
 	/**
     * Method name  : loadRecordTypeMap
     * Description  : This method returns the record type of the SObject passed in the argument.
     * Return Type  : Map<String, Id>
     * Parameter    : Schema.SObjectType
     **/
 	public static Map<String, Id> loadRecordTypeMap(Schema.SObjectType token){
 		if(recordTypeMap == null){
 			recordTypeMap = new Map<String, Id>();
	 		// Get the Describe Result
		    Schema.DescribeSObjectResult obj = token.getDescribe();
		
		    // Obtain ALL Active Record Types for the given SObjectType token
		    String soql = 
		        'SELECT Id, DeveloperName '
		        + 'FROM RecordType '
		        + 'WHERE SObjectType = \'' + String.escapeSingleQuotes(obj.getName()) + '\' '
		        + 'AND IsActive = TRUE';
		    List<RecordType> results;
		    try {
		        results = Database.query(soql);
		    } catch (Exception ex) {
		    	System.debug(ex.getMessage());
		        results = new List<SObject>();
		    } 
	        for (RecordType recordType : results) {
	            recordTypeMap.put(recordType.DeveloperName, recordType.Id);
	        }
 		} 
 		return recordTypeMap;  
 	}
}