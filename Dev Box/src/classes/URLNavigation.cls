public class URLNavigation {

    public List<URL_Parameter__c> listUrlParams;
    public List<WrapperSelection> listWrapperParams; 
    
    public List<WrapperSelection> listParams{
    get
    {
        listUrlParams = URL_Parameter__c.getAll().values();
        listWrapperParams = new List<WrapperSelection>();
        if(!listUrlParams.isEmpty())
        {
            for(URL_Parameter__c oParams : listUrlParams)
            {
               WrapperSelection oParamsValues = new WrapperSelection();
               oParamsValues.oInnerClass = oParams;
               listWrapperParams.add(oParamsValues);
            }
        }
        return listWrapperParams;
     }
     set;
    }
    
    public PageReference ClickMe()
    {
        PageReference oPageNavigate = null;
        
        for(WrapperSelection oURL : listWrapperParams)
        {
            if(oURL.bSelected)
            {
                oPageNavigate = new PageReference(oURL.oInnerClass.WebSite__c);
            }
        }
        
        return oPageNavigate;
    }
    
    //Inner Class
    public class WrapperSelection
    {
        public URL_Parameter__c oInnerClass{get;set;}
        public boolean bSelected {get;set;}
    
    }
}