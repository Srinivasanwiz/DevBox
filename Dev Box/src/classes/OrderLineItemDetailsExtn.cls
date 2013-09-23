public class OrderLineItemDetailsExtn {
    public Id orderDetailsId;
    public List<Menu__c> listMenuItems{get;set;}
    public Integer strQuantity{get;set;}
    public OrderLineItemDetailsExtn(ApexPages.StandardController controller) {
        orderDetailsId = System.currentPageReference().getParameters().get('orderid');
        listMenuItems = new List<Menu__c>();
        strQuantity = 0;
    }
    
    public void initiate(){
        listMenuItems  = [select Id, Name,Food_Image__c, Food_Type__c ,Category__c, Sub_Category__c,List_Price__c from Menu__c limit 100];
    }
    
    public PageReference AddOrderLineItem(){
        List<Order_Line_Item__c> listOLI = new  List<Order_Line_Item__c>();
        if(strQuantity != 0){
            for(Menu__c oMenu : listMenuItems  ){
            listOLI.add(new Order_Line_Item__c(Menu__c = oMenu.Id,
                                               Quantity__c = strQuantity , 
                                               Unit_Price__c = oMenu.List_Price__c,
                                               Order_Details__c = orderDetailsId
                                                ));
            }
            insert listOLI;
            
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.warning,'You need to enter Quantity'));
        }
        return  null;
    }
}