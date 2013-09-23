/*****************************************************************************************
    Name    : ForecastController 
    Desc    : Used for implementing cusotm visualforce page logic for forecast. This will display the forecast weeks in a gird like 
    		  table for all the weeks of the quarter, it is having the ability to add the forecase weeks by selecting the division 
    		  it also updates and saves the forecast values for the weeks.
                            
    Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       5/27/2013          Created
******************************************************************************************/
public with sharing class ForecastController{
   
   public List<Forecast_Qua__c> lstForecastQua{get;set;}
   public Forecast_Qua__c forecast{get;set;}
   public Forecast_Week__c forecastWeek{get;set;}   
   public List<clsForecast> clsForeCastList{get;set;}
   public Forecast_Year__c forecastYear{get;set;} 
   Public List<Period> PeriodList = new List<Period>();
   public List<Integer> indexList{get;set;}
   public Set<Integer> indexSet{get;set;}
   public List<Forecast_Year__c> lstForecastYear{get;set;}
   public String divisionName{get;set;}
   Public ID forecastYearId;
   Public String FYear{get;set;}
   Public String FQuarter{get;set;}
   Public String sortExp = 'name';
   Public String sortDirection = 'ASC';
   Public String FAccount;
   Public Id QuarterId;
   Public String FQName;
   Public String AddDivision;
   Public String alertForecast{get;set;}
   Public String alertUserDivision{get;set;}
   Public String FCurrency{get;set;}
   public boolean is14Week{get;set;}
   Public Boolean isForecastAccount;
   
   /**
     * Method name  : sortExpression
     * Description  : This method is to set and get the sort dirrection
     * Return Type  : String
     * Parameter    : None
     **/
   public String sortExpression{
       get{
          return sortExp;
       }
       set{
          //if the column is clicked on then switch between Ascending and Descending modes
          if ('Division__c' == sortExp)
            sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
          else
            sortDirection = 'ASC';
          
          sortExp = 'Division__c';
       }
   }
   
   /**
     * Method name  : getSortDirection
     * Description  : This method is to get the sort dirrection
     * Return Type  : String
     * Parameter    : None
     **/
   public String getSortDirection(){
     //if not column is selected 
     if (sortExpression == null || sortExpression == '')
        return 'ASC';
     else
        return sortDirection;
   }
   
   /**
     * Method name  : setSortDirection
     * Description  : This method is to set the sort dirrection
     * Return Type  : Void
     * Parameter    : value
     **/
   public void setSortDirection(String value){  
      sortDirection = value;
   }
   
   public ForecastController(){
   	
   }
   
   /**
     * Method name  : ForecastController
     * Description  : Constructor of the Controller class - Initializes all the variables.
     *                Populates forecast quarter data into forecast list
     * Return Type  : Void
     * Parameter    : StandardController
     **/
   public ForecastController(ApexPages.StandardController controller) {
   	   //not null check for Id
   	   if(ApexPages.CurrentPage().getParameters().get('id') == null){
   	   	   ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'No records found.');
           ApexPages.addMessage(msg); 
           return;  
   	   }
   	   //if the Id is not null, assign the value to QuarterId
       QuarterId = ApexPages.CurrentPage().getParameters().get('id');
   	   forecast = new Forecast_Qua__c();
   	   forecastWeek = new Forecast_Week__c();
   	   List<Forecast_Qua__c> fqList = new List<Forecast_Qua__c>();
   	   //query all the forecast week records related to forecastquarter Id
   	   fqList = [Select Name, Forecast_Year__c, Forecast_Year__r.Year__c, Forecast_Division__c, Forecast_Year__r.Account__c, FQ__c, Forecast_Year__r.account__r.CurrencyIsoCode, Forecast_Year__r.account__r.Forecast_Account__c  from Forecast_Qua__c where ID =: QuarterId limit 1];
   	   if(fqList.size() <= 0){
   	  	  ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'No records found.');
          ApexPages.addMessage(msg); 
          return;
   	   }
   	   forecastYear = new Forecast_Year__c();
       clsForeCastList = new List<clsForecast>();   
   	   Forecast_Qua__c fyid = fqList.get(0); 
   	   
   	   // assign values of Forecast Year, Forecast Quarter Name, forcast account values
       forecast.FQ__c = fyid.FQ__c;
       forecast.Forecast_Division__c = fyid.Forecast_Division__c;
       FQName = fyid.Name;
       forecastYearId = fyid.Forecast_Year__c;
       FYear = fyid.Forecast_Year__r.Year__c;
       FAccount = fyid.Forecast_Year__r.Account__c; 
       FCurrency = fyid.Forecast_Year__r.account__r.CurrencyIsoCode;
       isForecastAccount = fyid.Forecast_Year__r.account__r.Forecast_Account__c;
       is14Week = false;
       //check for Forecast quarter Q4
       if(forecast.FQ__c == 'Q4'){
       	  is14Week = true;	
       }
       
       indexList = new List<Integer>();
       indexSet = new Set<Integer>();
   	   Integer lastCounter = 13;
   	   if(forecast.FQ__c == 'Q4'){
          lastCounter = 14;	
       }
       for(Integer weekCounter = 1; weekCounter <= lastCounter; weekCounter++){
       	   indexList.add(weekCounter);
       	   indexSet.add(weekCounter);	   
       }
   }
   
   /**
     * Method name  : loadForecastData
     * Description  : Method to load the forecast visualforce with data from the forecast week object
     * Return Type  : Void
     * Parameter    : None
     **/
   public void loadForecastData(){
      //query all the forecast week object related to a forecast quarter, its year and quarter name
      List<Forecast_Week__c> forecastWeekList = new List<Forecast_Week__c>();
      forecastWeekList = [Select Id, Actual__c, Forecast__c, Division__c, Week__c, Week_Start_Date__c, Target__c, Variance__c, Week_Index__c from Forecast_Week__c 
      where Forecast_Quarter__r.FQ__c =: forecast.FQ__c and Forecast_Quarter__r.Forecast_Year__r.Year__c =: FYear and 
      Forecast_Quarter__r.Forecast_Year__r.Account__c =: FAccount and Forecast_Quarter__r.Name =: FQName order by CreatedDate DESC];
      
      if(forecastWeekList.size() > 0){
      	  Set<String> divisionSet = new Set<String>();
      	  for(Forecast_Week__c forecastWeek : forecastWeekList){
      	     if(forecastWeek.Division__c != null){	 
      	       divisionSet.add(forecastWeek.Division__c);
      	     }  
      	  }
      	  for(String div : divisionSet){
      	  	clsForecast fore = new clsForecast();
            fore.division = div; 
            Integer target = 0;
            
            fore.weekList = new List<clsForecast.clsWeek>();
            fore.weekMap = new Map<Integer, boolean>();
            Double forecastTotal = 0, actualTotal = 0; 
            clsForecast.clsWeek week;
            //used to iterate the for loop, if quarter 4 the 14 weeks, and for other quarters 13 weeks  
            Integer lastCounter = 13;
            
            if(forecast.FQ__c == 'Q4'){
            	lastCounter = 14;	
            }
            for(Integer weekCounter = 1; weekCounter <= lastCounter; weekCounter++){
	      	   for(Forecast_Week__c fcWeek : forecastWeekList){
	      	  	  if(div == fcWeek.Division__c && fcweek.Week__c == 'Week '+weekCounter){
	      	  	  	 week = new clsForecast.clsWeek();
	      	  	  	 week.forecastWeek = fcWeek;
	                 week.wid = fcWeek.id;
	                
	                 week.weekName = fcWeek.Week__c; 
	                 if(week.weekName == 'Week 1' && fcWeek.Target__c != null){
						 target = Integer.valueOf(fcWeek.Target__c);                  	
	                 }
	                 if(fcWeek.Forecast__c != null){
	                    forecastTotal = forecastTotal + Double.valueOf(fcWeek.Forecast__c);
	                 }
	                 if(fcWeek.Actual__c != null){ 
	                    actualTotal = actualTotal + Double.valueOf(fcWeek.Actual__c);	
	                 }
	                 fore.weekList.add(week);
	                 fore.weekMap.put(weekCounter, true);  	
	      	  	  }	      	  	  
	      	   }
            }
            fore.weekIndexList = indexList;
            Set<Integer> keySet = fore.weekMap.keySet(); 
            for(Integer weekCounter = 1; weekCounter <= lastCounter; weekCounter++){
            	if(!keySet.contains(weekCounter)){
            		fore.weekMap.put(weekCounter, false);  	
					week = new clsForecast.clsWeek();
					Forecast_Week__c fcWeek = new Forecast_Week__c();
					fcWeek.Week_Index__c = weekCounter;
					week.forecastWeek = fcWeek;
					fore.weekList.add(week);      		
            	}
            }
            
      	    fore.weekTarget = target;
      	    fore.varianceForecast = 0;
      	    //calculate the variance forecast value from target
      	    fore.varianceForecast = target - forecastTotal;
      	    
      	    fore.varianceActual = 0;
      	    //calculate the variance actual value from target
      	    fore.varianceActual = target - actualTotal; 
      	    clsForeCastList.add(fore);
      	    system.debug('clsForeCastList' + clsForeCastList);
      	  }  	 
      }
   }
   
   /**
     * Method name  : addRow
     * Description  : Method to add  the row into the forecast visualforce page with all the weeks of the quarter
     *				  user should select divion before adding the row
     * Return Type  : Void
     * Parameter    : Nil
     **/ 
   public void addRow(){
   	try{
	        if(forecastWeek.Division__c == null){
	           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Please select Division.');
	           ApexPages.addMessage(msg);           
	           return;
	        }
	        
	        List<Forecast_Week__c> forecastList1 = new List<Forecast_Week__c>();
	        List<clsForecast> forecastList;
	        
	        //query all the forecast week object related to a forecast quarter, its year and quarter name
	        forecastList1  = [Select Division__c, Actual__c, Forecast__c, Week__c, Week_Start_Date__c, Week_Index__c from Forecast_Week__c 
	        where Division__c =: forecastWeek.Division__c and Forecast_Quarter__r.FQ__c =: forecast.FQ__c and 
	        Forecast_Quarter__r.Forecast_Year__r.Year__c =: FYear and Forecast_Quarter__r.Forecast_Year__r.Account__c =: FAccount 
	        and Forecast_Quarter__r.Name =:FQName order by Week__c]; 	
	        //if the selected division already exists in the quarter, it gives error message.
	        if(forecastList1.size() > 0){
	           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Division ' + forecastWeek.Division__c + ' for forecast ' + forecast.FQ__c + ' already exists.');
	           ApexPages.addMessage(msg); 
	           return;  
	        }else{
	        	// if the division does not exists, then add the division and its corresponding weeks  
	           forecastList = new List<clsForecast>();
	           clsForecast fore = new clsForecast();
	           fore.division = forecastWeek.Division__c;
	           fore.weekTarget = 0;
	          
	           fore.weekList = new List<clsForecast.clsWeek>();
	           fore.weekMap = new Map<Integer, boolean>();
	           clsForecast.clsWeek week = new clsForecast.clsWeek();
	           for(integer i = 1; i <= 13; i++){
	           	 week = new clsForecast.clsWeek();
	           	 week.weekName = 'Week ' + i;
	           	 //week.target = 0;
	           	 fore.weekList.add(week);
	           	 fore.weekMap.put(i, true);
	           }   
			   if(forecast.FQ__c == 'Q4'){
	           	  week = new clsForecast.clsWeek();
	           	  week.weekName = 'Week 14';
	           	  fore.weekMap.put(14, true);
	           	  fore.weekList.add(week);
	           }               
	           forecastList.add(fore); 
	                                 
	           for(clsForeCast quarter : clsForeCastList){              
	              forecastList.add(quarter);  
	           }
	           clsForeCastList = forecastList;
	        }
	       
	        Integer weekNumberStart;
	        Integer weekNumberEnd;
	        //calculate start and end week numbers based on the quarter values
		    if (forecast.FQ__c == 'Q1'){
			  weekNumberStart = 1;
			  weekNumberEnd = 13;
		    }else if(forecast.FQ__c == 'Q2'){
			  weekNumberStart = 14;
			  weekNumberEnd = 26;
		    }else if(forecast.FQ__c == 'Q3'){
			  weekNumberStart = 27;
			  weekNumberEnd = 39;
		    }else if(forecast.FQ__c == 'Q4'){
			  weekNumberStart = 40;
			  weekNumberEnd = 52;
		    }
		    List<Forecast_Week__c> fweekList = new List<Forecast_Week__c>();
		    Integer weekIndex = 0;
	    	for(clsForecast.clsWeek week : clsForeCastList.get(0).weekList){
	    	   if(weekNumberStart <= weekNumberEnd){
	    	 	  for(Period p : [Select StartDate from Period where Number =: weekNumberStart Limit 1 ]){	
		    		  Forecast_Week__c foreWeek = new Forecast_Week__c();
		    		  weekIndex = weekIndex + 1;
			    	  foreWeek.Forecast_Quarter__c = QuarterId;
		              foreWeek.Division__c = forecastWeek.Division__c;
		              if(week.weekName == 'Week 1'){
			    	  	 foreWeek.Target__c = 0;
	    	 	      }
			    	  foreWeek.Forecast__c = 0;
			    	  foreWeek.Week_Index__c = weekIndex; 
			    	  //foreWeek.Week__c = week.weekName;
			    	  foreWeek.Week_Start_Date__c = p.StartDate;
			    	  foreWeek.CurrencyIsoCode = FCurrency;
			    	  //foreweek.Actual__c = 0;
			    	  
			    	  weekNumberStart++;
			    	  //insert foreWeek;
			    	  fweekList.add(foreWeek);
	    	 	  }
	    	   } 		
	    	}
	    	//if quarter 4 then add the last week to week index as 14
	    	if(weekNumberStart == 53 && forecast.FQ__c == 'Q4'){
    	   		Period p = [Select StartDate from Period where Number =: 53 Limit 1]; 
			  	Forecast_Week__c foreWeek = new Forecast_Week__c();
	    	    foreWeek.Forecast_Quarter__c = QuarterId;
                foreWeek.Division__c = forecastWeek.Division__c;
	    	    foreWeek.Forecast__c = 0;
	    	    //foreWeek.Week__c = 'Week 14';
	            foreWeek.Week_Index__c = 14;
	   	        foreWeek.Week_Start_Date__c = p.StartDate;
	    	    foreWeek.CurrencyIsoCode = FCurrency;
	    	    fweekList.add(foreWeek);
    	    }
	    	insert fweekList;
	    	List<Id> weekIdList = new List<Id>();
	    	for(Forecast_Week__c fweek : fweekList){ 
	    		weekIdList.add(fweek.Id);
	    	}
	    	fweekList = [Select Id, Forecast_Quarter__c, Target__c, Variance__c, Division__c, Actual__c, Forecast__c, Week__c, Week_Start_Date__c, Week_Index__c from
	    	Forecast_Week__c where Id IN: weekIdList]; 
	        for(clsForecast.clsWeek week : clsForeCastList.get(0).weekList){
	        	for(Forecast_Week__c fweek : fweekList){
					if(week.weekName == fweek.Week__c){
						week.forecastWeek = fweek;
						week.wid = fweek.Id;
					}	        		
	        	}
	        }
	        is14Week = false;
	        if(forecast.FQ__c == 'Q4'){
	       	  is14Week = true;	
	        }
    	}catch(System.Exception ex){
            //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An unexpected exception occured. Please contact your System Admin'));
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Navigate back to Account and Select Fiscal Year and Fiscal Quarter to Continue.'));
            System.debug('###Exception : '+ex.getMessage());
            //return null;    
        }        
        return;          
    }    
    
   /**
     * Method name  : UpdateForecast
     * Description  : Method to save the forecast week data entered by the user in the visualforce page
     * Return Type  : Void
     * Parameter    : Nil
     **/
    public PageReference UpdateForecast(){  
    	Set<ID> CurrentQuarterId = new Set<ID>();
    	PageReference pageReference = new PageReference('/'+FAccount);
    	try{
    		List<Forecast_Week__c> forecastUpdate = new List<Forecast_Week__c>();
    		List<Forecast_Week__c> forecastWeekList = new List<Forecast_Week__c>();
    		//query the forecast week to be updated
			forecastWeekList = [Select Id, Week__c, Actual__c, Target__c, Division__c, Forecast__c, Week_Index__c from Forecast_Week__c where 
			Forecast_Quarter__c =: QuarterId order by Week__c];	    	
    		for(clsForecast fcl : clsForeCastList){
    	   	   for(clsForecast.clsWeek fw : fcl.weekList){
    	   	   	  Integer index = Integer.valueOf(fw.forecastWeek.Week_Index__c);
    	   	   	  if(fcl.weekMap.get(index)){
    	   	   	    // target is updated on Week 1 
	                if(fw.weekName == 'Week 1'){
	              	  fw.forecastWeek.Target__c = fcl.weekTarget;
	                }
	                forecastUpdate.add(fw.forecastWeek);
    	          }
    	   	   }   
    	   }  
	       update forecastUpdate;
    	}catch(System.Exception ex){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Forecast_Owner_Permission));
            return null;
        }
        return pageReference;
    }
    
    /**
     * Method name  : deleteRow
     * Description  : Method to delete the row from the forecase visualforce page, if the user feels that row is added by mistake 
     * Return Type  : Void
     * Parameter    : Nil
     **/
    public void deleteRow(){
    	System.debug('division: '+divisionName);
    	Integer i = 0;
    	for(clsForecast fcl : clsForeCastList){
    	   if(fcl.division == divisionName){
    	   	  break;
    	   }	
    	   i = i + 1;	
    	}
    	clsForeCastList.remove(i);
    	List<Forecast_Week__c> forecastList = new List<Forecast_Week__c>();
        
        forecastList = [Select Id from Forecast_Week__c where Division__c =: divisionName and Forecast_Quarter__c =: QuarterId];
        delete forecastList; 
        
        List<Account> acctList = new List<Account>();
   	    acctList = [Select Id, Division__c from Account where ID =: FAccount];
   	    Forecast_Qua__c fq = [Select Id, Forecast_Division__c from Forecast_Qua__c where ID =: QuarterId limit 1];
   	    String[] divisions;
        if(acctList.get(0).Division__c != null){
           Account accountDivision = acctList.get(0);
           if(accountDivision.Division__c != null){
           	  String div = accountDivision.Division__c;
           	  div = div + ';';
           	  divisions = div.split(';');
           }
           Set<String> divSet = new Set<String>();
           for(Integer j = 0; j <= divisions.size() - 1; j++){
             divSet.add(divisions[j]);
           }
           String fqd = fq.Forecast_Division__c + ';';
           System.debug('divSet: '+divSet);
           System.debug('divisionName: '+divisionName);
           System.debug('fqd: '+fqd);
           if(divSet.size() > 0 && divSet.contains(divisionName) && !fqd.contains(divisionName)){
        	  fq.Forecast_Division__c = fqd + divisionName;
        	  update fq;
           } 
        }   
    }
    
   /**
     * Method name  : sortColumns
     * Description  : Method is used to sort columns. 
     * Return Type  : Void
     * Parameter    : Nil
     **/   
    public void sortColumns(){
       clsForeCastList.sort();
       if(sortDirection == 'DESC'){
       	  List<clsForecast> clsList = new List<clsForecast>();
       	  for(integer i = clsForeCastList.size()-1; i >= 0; i--){
             clsList.add(clsForeCastList[i]);
          }
          clsForeCastList = clsList;
       }
   }
   
   /**
     * Method name  : loadData
     * Description  : Method to add the rows in the forecast week column which will be displayed in forecase visualforce page.
     *				  based on the division selected by the user in the accout page under "Forecast Settings" section 
     * Return Type  : Void
     * Parameter    : Nil
     **/
   public void loadData(){
   	 //Start
	   	 try{
		   
		   /*Integer weekNumberStart;
    	   Integer weekNumberEnd;
		   Map<Integer, Date> perdioDateMap = new Map<Integer, Date>();				
		   List<Period> periodList = [Select Number, StartDate from Period];
		   for(Period period :  periodList){
		   	   perdioDateMap.put(period.Number, period.StartDate);
		   } 	
  		   if (forecast.FQ__c == 'Q1'){
	  		   weekNumberStart = 1;
	  		   weekNumberEnd = 13;
    	   }else if(forecast.FQ__c == 'Q2'){
	  		   weekNumberStart = 14;	
	  		   weekNumberEnd = 26;
    	   }else if(forecast.FQ__c == 'Q3'){
	  		   weekNumberStart = 27;
	  		   weekNumberEnd = 39;
    	   }else if(forecast.FQ__c == 'Q4'){
	  		   weekNumberStart = 40;
	  		   weekNumberEnd = 52;
    	   }*/
		   		   	 	
	       Set<String> divisionSet = new Set<String>();  
           List<Forecast_Week__c> forecastWeekList = new List<Forecast_Week__c>();
           Map<String, Set<Integer>> divisionWeekMap = new Map<String, Set<Integer>>();
           Map<String, Set<Integer>> divisionWeekMap1 = new Map<String, Set<Integer>>();
		   //query the forecast week to be updated
		   forecastWeekList = [Select Id, Week__c, Division__c, Forecast__c, Week_Index__c, Week_Start_Date__c from Forecast_Week__c where
           					   Forecast_Quarter__c =: QuarterId order by Division__c];
           for(Forecast_Week__c week : forecastWeekList){
           	  divisionSet.add(week.Division__c);
           }
           for(String div : divisionSet){
			  Set<Integer> wIndexSet = new Set<Integer>();	           	
           	  for(Forecast_Week__c week : forecastWeekList){
           	  	  if(div == week.division__c){
           	  	  	 wIndexSet.add(Integer.valueOf(week.Week_Index__c));
           	  	  }	  
           	  }
           	  divisionWeekMap.put(div, wIndexSet);	           	  
           }
           for(String div : divisionWeekMap.keySet()){
           	  Set<Integer> wIndexSet = new Set<Integer>();
              for(Integer index : indexList){
              	 if(!divisionWeekMap.get(div).contains(index)){
              	 	 wIndexSet.add(index);
              	 }	  
              }
              divisionWeekMap1.put(div, wIndexSet); 	 		
           }
	       Integer c = 0;  
	       List<Forecast_Week__c> fweekList1 = new List<Forecast_Week__c>();
  		   for(String div : divisionWeekMap1.keySet()){
  		  	  for(Integer index : divisionWeekMap1.get(div)){
  		  	  	  Forecast_Week__c foreWeek = new Forecast_Week__c();
	    	      foreWeek.Forecast_Quarter__c = QuarterId;
                  foreWeek.Division__c = div;
	    	      foreWeek.Forecast__c = 0;
	    	      foreWeek.Week_Index__c = index;
	    	      //foreWeek.Week_Start_Date__c = week.Week_Start_Date__c;
	    	      foreWeek.CurrencyIsoCode = FCurrency;
	    	      fweekList1.add(foreWeek);
  		  	  }
  		   }
	       if(fweekList1.size() > 0){
	       	   insert fweekList1;
	       }
	   	 	
	   	 	//load data to load all the divison wise week data, if any divisions are not existing from User division field, then it adds them
	   	    List<Account> AcctList = new List<Account>();
	   	    AcctList = [Select Id, Division__c from Account where ID =: FAccount];
	   	    String[] divisions, divArray;
	   	    System.debug('inside');
	        if(AcctList.get(0).Division__c != null){
	           String fdiv = forecast.Forecast_Division__c;
	           fdiv = fdiv + ';';
	           divArray = fdiv.split(';');
	           Set<String> divSet = new Set<String>();
	           for(Integer i = 0; i <= divArray.size() - 1; i++){
	              divSet.add(divArray[i]);
	           }   
	           Account AccountDivisionList = AcctList.get(0);
	           if(AccountDivisionList.Division__c != null){
	           	  String div = AccountDivisionList.Division__c;
	           	  div = div + ';';
	           	  divisions = div.split(';');
	           }
	           Set<String> naDivisionSet = new Set<String>();
	           if (divisions.size() > 0) {
	           	  List<Forecast_Week__c> fqDivList = [Select division__c from Forecast_Week__c where Forecast_Quarter__c =: QuarterId];
	       	      for(Integer i = 0; i <= divisions.size() - 1; i++){
	       	      	 boolean flag = false;
	       	      	 //iterate through the division wise forecast week list, and remove any already existing division
	      		     for(Forecast_Week__c fwc : fqDivList){
	      	 		     if(fwc.division__c == divisions[i]){
	      	 			    //divisions.remove(i);
	      	 			    naDivisionSet.add(divisions[i]);
	      	 			    flag = true;
	      	 		     }	      	 		     
	      	         }
	      	         if(divSet.size() > 0 && divSet.contains(divisions[i]) && !flag){
	      	 		 	//divisions.remove(i);
	      	 		 	naDivisionSet.add(divisions[i]);    	
	      	 		 }	      	 		 
	      		  } 
	           } 
	           System.debug('**naDivisionSet: '+naDivisionSet);
	           System.debug('**divisions: '+divisions);
	           List<String> aDivision = new List<String>();
	           if(naDivisionSet.size() > 0){
	           	   Integer k = 0;
	           	   for(Integer i = 0; i <= divisions.size() - 1; i++){
	           	   	  if(!naDivisionSet.contains(divisions[i])){
						 aDivision.add(divisions[i]);
	           	   	  } 
	           	   }
				   divisions = aDivision;		           	   
	           }
	           //used to add any additional division wise week data which are there in the User Division field but not existing in the Week object
	           if(divisions.size() > 0){
	      	       List<Forecast_Week__c> fweekList = new List<Forecast_Week__c>();
	        	   Integer weekNumberStart;
	        	   Integer weekNumberEnd;
	      		   System.debug('CallAddRow');
	      		   for(integer j = 0; j < divisions.size(); j++){
	      		      if (forecast.FQ__c == 'Q1'){
			  			weekNumberStart = 1;
			  			weekNumberEnd = 13;
		    		  }else if(forecast.FQ__c == 'Q2'){
			  			weekNumberStart = 14;	
			  			weekNumberEnd = 26;
		    		  }else if(forecast.FQ__c == 'Q3'){
			  			weekNumberStart = 27;
			  			weekNumberEnd = 39;
		    		  }else if(forecast.FQ__c == 'Q4'){
			  			weekNumberStart = 40;
			  			weekNumberEnd = 52;
		    		  }
	   
	    			  for(integer i = 1; i <= 13; i++){
	    	   			if(weekNumberStart <= weekNumberEnd){
	    	 	  			for(Period p : [Select StartDate from Period where Number =: weekNumberStart Limit 1 ]){	
				    		    Forecast_Week__c foreWeek = new Forecast_Week__c();
					    	    foreWeek.Forecast_Quarter__c = QuarterId;
				                foreWeek.Division__c = divisions[j];
					    	    foreWeek.Forecast__c = 0;
					    	    foreWeek.Week_Index__c = i;
					    	    foreWeek.Week_Start_Date__c = p.StartDate;
					    	    foreWeek.CurrencyIsoCode = FCurrency;
					    	    weekNumberStart++;
					    	    fweekList.add(foreWeek);
	    	 	  		    }
	    	   			 } 		
	    			  } 
	    			  if(forecast.FQ__c == 'Q4'){
	    			  	 Period p = [Select StartDate from Period where Number =: 53 Limit 1]; 
	    			  	 Forecast_Week__c foreWeek = new Forecast_Week__c();
			    	     foreWeek.Forecast_Quarter__c = QuarterId;
		                 foreWeek.Division__c = divisions[j];
			    	     foreWeek.Forecast__c = 0;
			    	     foreWeek.Week_Index__c = 14;
			    	     foreWeek.Week_Start_Date__c = p.StartDate;
			    	     foreWeek.CurrencyIsoCode = FCurrency;
			    	     fweekList.add(foreWeek);
	    			  } 
	      		  }
	      		  if(fweekList.size() > 0){
	      	         insert fweekList;
	      		  }   
	      	  }
	       }
	    }catch(System.Exception ex){
	       System.debug('###Exception : '+ex.getMessage());
	    }
	    loadForecastData();
   }
   
   /**
     * Method name  : ForecastAlert
     * Description  : Method to display the pop-up messages to the user when the user open the account and if forecase year, forecase quarter
     *				  and forecase week is not created for that account. 
     * Return Type  : Void
     * Parameter    : Nil
     **/
     public void ForecastAlert(){
     	alertForecast ='';
     	ID userID =  Userinfo.getUserId();
     	List<User> userList = new List<User>();
     	userList = [Select division__c from user where id =:userID Limit 1];
     	alertUserDivision = userList.get(0).division__c;
     	//get the account week, quarter, and year data related to Account record 
     	try{
		     	ID AccountID =	 ApexPages.CurrentPage().getParameters().get('id');
		     	List <Forecast_Year__c> yearList = new List<Forecast_Year__c>();
		     	List <Forecast_Qua__c> quarterList = new List<Forecast_Qua__c>();
		     	List<Forecast_Week__c> weekList = new List<Forecast_Week__c>();
		       	Integer CurrentYear = datetime.now().year();
		       	Integer CurrentMonth = datetime.now().month();
		       	
		     	system.debug('CurrentMonth' +CurrentMonth);
		     	//get the Forecast Year data matching for account records 
		     	yearList = [Select ID,Year__c from Forecast_Year__c  where Year__c =: String.Valueof(CurrentYear) and Account__c =:AccountID limit 1];
		     	if(yearList.size()>0){
		     		//query the quarter as per the values Q1, Q2, Q3, Q4
		     		if(CurrentMonth <= 3 ){
		     			quarterList = [Select ID, FQ__C from  Forecast_Qua__c where Forecast_Year__c =:yearList.get(0).ID and FQ__c ='Q1'];
		     		}else if(CurrentMonth >= 4 & CurrentMonth <=6){
		     			quarterList = [Select ID, FQ__C from  Forecast_Qua__c where Forecast_Year__c =:yearList.get(0).ID and FQ__c ='Q2'];
		     		}else if(CurrentMonth >= 7 & CurrentMonth <=9){
		     			quarterList = [Select ID, FQ__C from  Forecast_Qua__c where Forecast_Year__c =:yearList.get(0).ID and FQ__c ='Q3'];
		     		}else if(CurrentMonth >= 10 & CurrentMonth <=12){
		     			quarterList = [Select ID, FQ__C from  Forecast_Qua__c where Forecast_Year__c =:yearList.get(0).ID and FQ__c ='Q4'];
		     		}
		     		
		     	}
		     	
		     	if(quarterList.size()>0){
		     		if(CurrentMonth <= 3 ){
		     			for(Forecast_Qua__c fw :quarterList){
		     				weekList = [Select ID, week__c from  Forecast_Week__c where Forecast_Quarter__r.FQ__c ='Q1' and Forecast_Quarter__c =:quarterList.get(0).ID ];	
		     			}
		     		}else if(CurrentMonth >= 4 & CurrentMonth <=6){
		     			for(Forecast_Qua__c fw :quarterList){
		     				weekList = [Select ID, week__c from  Forecast_Week__c where Forecast_Quarter__r.FQ__c ='Q2' and Forecast_Quarter__c =:quarterList.get(0).ID];	
		     			}
		     		}else if(CurrentMonth >= 7 & CurrentMonth <=9){
		     			for(Forecast_Qua__c fw :quarterList){
		     				weekList = [Select ID, week__c from  Forecast_Week__c where Forecast_Quarter__r.FQ__c ='Q3' and Forecast_Quarter__c =:quarterList.get(0).ID];	
		     			}
		     		}else if(CurrentMonth >= 10 & CurrentMonth <=12){
		     			for(Forecast_Qua__c fw :quarterList){
		     				weekList = [Select ID, week__c from  Forecast_Week__c where Forecast_Quarter__r.FQ__c ='Q4' and Forecast_Quarter__c =:quarterList.get(0).ID];	
		     			}
		     		}
		     	}
		     	system.debug('yearList' +yearList);
		     	if(yearList.size()==0){
		     		alertForecast = 'Please enter forecast for the Year '+String.Valueof(CurrentYear);
		     		return;
     			}
     			//alert message as per the month values, if quarter is not present
     			if(quarterList.size()==0 ){
     				if(CurrentMonth <= 3 ){
		     			alertForecast = 'Please enter forecast for the Quarter Q1';
		     			return;
		     		}else if(CurrentMonth >= 4 & CurrentMonth <=6){
		     			alertForecast = 'Please enter forecast for the Quarter Q2';
		     			return;
		     		}else if(CurrentMonth >= 7 & CurrentMonth <=9){
		     			alertForecast = 'Please enter forecast for the Quarter Q3';
		     			return;
		     		}else if(CurrentMonth >= 10 & CurrentMonth <=12){
		     			alertForecast = 'Please enter forecast for the Quarter Q4';
		     			return;
		     		}
     			}
     			
     			//alert message as per the week values, if weeks are not present
     			if(weekList.size()==0){
     				if(CurrentMonth <= 3 ){
		     			alertForecast = 'Please enter forecast weeks for the Quarter Q1';
		     			return;
		     		}else if(CurrentMonth >= 4 & CurrentMonth <=6){
		     			alertForecast = 'Please enter forecast weeks for the Quarter Q2';
		     			return;
		     		}else if(CurrentMonth >= 7 & CurrentMonth <=9){
		     			alertForecast = 'Please enter forecast weeks for the Quarter Q3';
		     			return;
		     		}else if(CurrentMonth >= 10 & CurrentMonth <=12){
		     			alertForecast = 'Please enter forecast weeks for the Quarter Q4';
		     			return;
		     		}
     			}
     			
     	}catch(System.Exception ex){
	         Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An unexpected exception occured. Please contact your System Admin'));
	         System.debug('###Exception : '+ex.getMessage());
        }
   }
   public boolean displayPopup {get; set;}     
    
   public void closePopup() {        
        displayPopup = false;    
   }     
    
   public void showPopup() {
      if((alertForecast!='') || (isForecastAccount == true) || (alertUserDivision=='Geospatial')) {
    	  displayPopup = true; 
      }       
   }    
}