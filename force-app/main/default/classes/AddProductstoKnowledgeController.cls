public class AddProductstoKnowledgeController{
    public string knowledgeId {get; set;}
    public list<wrapperAppModel> listWrapper {get; set;}
    public set<string> setAppModel;
    public list<Applicable_Model__c> listAppModel;
    
    public AddProductstoKnowledgeController(){
        setAppModel = new set<string>();
        listAppModel = new list<Applicable_Model__c>();
        listWrapper = new list<wrapperAppModel>();
        knowledgeId = ApexPages.CurrentPage().getparameters().get('id');
        for(Applicable_Model__c am : [select Product__c from Applicable_Model__c where Knowledge__c = :knowledgeId]){
            setAppModel.add(am.Product__c);
        }
        for(Product2 p : [Select Id, Name, ProductCode from Product2 where Id not in :setappModel]){
            listWrapper.add(new wrapperAppModel(false, p));
        }
    }
    public class wrapperAppModel{
        public boolean isSelected {get; set;}
        public Product2  product{get; set;}
        public wrapperAppModel(boolean isSelected, Product2 product){
            this.isSelected = isSelected;
            this.product = product;
        }
    }
    
    public pagereference Submit(){
        for(wrapperAppModel wam : listWrapper){
            if(wam.isSelected == true){
                Applicable_Model__c am = new Applicable_Model__c();
                am.Knowledge__c = knowledgeId;
                am.Product__c = wam.product.Id;
                listAppModel.add(am);
            }
        }
        insert listAppModel;
        PageReference pageRef = new PageReference('/' + knowledgeId);
        aura.redirect(pageRef);
        return pageRef;
    }
    public pagereference Cancel(){   
        PageReference pageRef = new PageReference('/' + knowledgeId);
        aura.redirect(pageRef);
        return pageRef;
    }
     
}