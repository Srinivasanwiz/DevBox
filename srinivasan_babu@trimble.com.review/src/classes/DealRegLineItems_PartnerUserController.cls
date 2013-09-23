/*****************************************************************************************
    Name    : DealRegLineItems_PartnerUserController 
    Desc    : 
                            
Modification Log : 
---------------------------------------------------------------------------
 Developer              Date            Description
---------------------------------------------------------------------------
Ashfaq Mohammed       4/27/2013          Created
******************************************************************************************/
public class DealRegLineItems_PartnerUserController {

    public integer quantity { get; set; }
    public boolean updatedealline{get;set;}
    public id dealId{get;set;}
    public id deallineId{get;set;}
    public Deal_Registration__c dealReg{get;set;}
    public Deal_Registration_Line__c dealRegLine{get;set;}    
    public Deal_Registration_Line__c drl;
    public  Map<Id,string> mapPrdIdUnitPrice;
    public integer UnitPrice{get;set;}
    
    public List<Product2> results{get;set;} // search results
    public string searchString{get;set;} // search keyword
    List<PricebookEntry> priceBookList = new List<PricebookEntry>();
   
    public DealRegLineItems_PartnerUserController(){
        dealId = ApexPages.currentPage().getParameters().get('id');   
        system.debug('dealId - > ' + dealId);
        deallineId =  ApexPages.currentPage().getParameters().get('lineid'); 
        system.debug('deallineId - > ' + deallineId);
        updatedealline = false;
        dealRegLine = new Deal_Registration_Line__c();
        if(dealid !=null){
            dealReg = [Select id,Name from Deal_registration__c where id=: dealId];
        }
        if(deallineId !=null){
            dealRegLine = [SELECT Deal_Registration__c,Id,Name,Product__c,Quantity__c,Total_Price__c,Unit_Price__c FROM Deal_Registration_Line__c where id=:deallineId ];
            dealReg = [Select id,Name from Deal_registration__c where id=: dealRegLine.Deal_Registration__c];
            quantity = integer.valueof(dealRegLine.Quantity__c);
            UnitPrice = integer.valueof(dealRegLine.Unit_Price__c);
            updatedealline = true;
        }       
        system.debug('dealReg - > ' + dealReg);
        system.debug('dealRegLine - > ' + dealRegLine);
        priceBookList  = new List<PricebookEntry>();
        PriceBook2 pbe2 = new PriceBook2();
        pbe2 = [Select id,name from PriceBook2 where name='Philips Lumileds Pricebook' limit 1];
        priceBookList  = [Select id,Product2Id,unitprice from PricebookEntry where Pricebook2Id =: pbe2.Id ];
        mapPrdIdUnitPrice = new Map<Id,string>();
        if(!priceBookList.isEmpty()){
            for( PricebookEntry pbe : priceBookList ){            
                mapPrdIdUnitPrice.put(pbe.Product2Id,string.valueof(pbe.UnitPrice));
            }
        }
    }    
    
    public PageReference Save() {
        if(dealId !=null){
            drl = new Deal_Registration_Line__c();   
            //drl.Product__c = product;
            system.debug('dealRegLine.Product__c - > ' + dealRegLine.Product__c);
            system.debug('mapPrdIdUnitPrice - > ' + mapPrdIdUnitPrice);
            drl.Product__c = dealRegLine.Product__c;
            drl.Quantity__c = quantity ;
            drl.Unit_Price__c = 0;
            if(mapPrdIdUnitPrice.size() > 0){
            	drl.Unit_Price__c = Decimal.valueof(mapPrdIdUnitPrice.get(dealRegLine.Product__c));	
            }
            drl.Deal_Registration__c = dealId;
            insert drl;
            return new pagereference ('/'+ dealId);
        }
        else{
            //dealRegLine.Product__c = product;
            dealRegLine.Quantity__c = quantity ;
            dealRegLine.Unit_Price__c = Decimal.valueof(mapPrdIdUnitPrice.get(dealRegLine.Product__c));        
            update dealRegLine;
            return new pagereference ('/'+ dealRegLine.id);
        }        
        
    }
    
    public pagereference cancel(){
        if(dealId != null)
            return new pagereference ('/'+ dealId);
        else{
            return new pagereference ('/'+ deallineId );
        }
    }

}