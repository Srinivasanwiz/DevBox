/*****************************************************************************************
    Name    : ForecastQuarterTrigger 
    Desc    : Trigger to check and alert when user create duplicate Quarter  for the same Year and also to update the name format field
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       6/13/2013          Created
******************************************************************************************/
trigger ForecastQuarterTrigger on Forecast_Qua__c (before insert) {
	Set<Id> yearSet = new Set<Id>();
	Set<String> fqSet = new Set<String>();
	Set<String> quarterSet = new Set<String>();
	Map<Id, Forecast_Year__c> forecastYearMap = new Map<Id, Forecast_Year__c>();
	List<Forecast_Qua__c> QuarterList = new List<Forecast_Qua__c>();
	
	//get all year data in a list
	for(Forecast_Qua__c fq :trigger.new){
		fqSet.add(fq.FQ__c);
		yearSet.add(fq.Forecast_Year__c);
	}
    //quarter list related to the new data inserted		
	QuarterList = [Select FQ__c, Forecast_Year__c from Forecast_Qua__c where Forecast_Year__c IN : yearSet and FQ__c IN: fqSet];	    
    for(Forecast_Qua__c quarter : QuarterList){
       quarterSet.add(quarter.FQ__c + '-' + quarter.Forecast_Year__c);	
    }
    
    List<Forecast_Year__c> forecastYearList = new List<Forecast_Year__c>();
    forecastYearList = [Select ID, Year__c, CurrencyIsoCode from Forecast_Year__c where ID IN : yearSet];
    
    for(Forecast_Year__c year : forecastYearList){
    	forecastYearMap.put(year.Id, year);
    }
    
	if(trigger.isbefore & trigger.isInsert){
		for(Forecast_Qua__c fq : trigger.new){
			if(quarterSet.contains(fq.FQ__c + '-' + fq.Forecast_Year__c)){
				//if forecast year already exists, then throw error
				fq.adderror('Forecast for the Quarter '+ fq.FQ__c + ' already exists');
			}else{
				Forecast_Year__c year = forecastYearMap.get(fq.Forecast_Year__c);
				fQ.Name_Format__c = 'FY-'+year.Year__c + '  FQ-' + fq.FQ__c;
				//update the currency code with that of the currency code of account record
				fq.CurrencyIsoCode = year.CurrencyIsoCode;
			}
		}
	}
}