/*****************************************************************************************
    Name    : clsForecast 
    Desc    : Wrapper class used to iterate forecast data 
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Sagar Mehta       6/10/2013          Created
******************************************************************************************/
global class clsForecast implements Comparable{
   public String division{get;set;}
   public Integer weekTarget{get;set;}
   public Double varianceForecast{get;set;}
   public Double varianceActual{get;set;}
   public List<clsWeek> weekList{get;set;}
   public List<Integer> weekIndexList{get;set;}
   public Map<Integer, boolean> weekMap{get;set;}
   //wrapper class to contain week related data
   public class clsWeek{
      public Id wid{get;set;}
      public Double target{get;set;}
      public String weekName{get;set;}
      public Forecast_Week__c forecastWeek{get;set;}
   }
   
   //compareTo method is used by sort API to sort the division field
   global Integer compareTo(Object objToCompare) {
      return division.compareTo(((clsForecast)objToCompare).division);
   }
}