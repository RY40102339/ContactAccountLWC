public class YODA_AddProductstoKnowledgeCtlr{
    public string knowledgeId {get; set;}
    //public list<wrapperAppModel> listWrapper {get; set;}
    public map<string, wrapperAppModel> mapWrapper {get; set;}
    public string search {get; set;}
    public set<string> setAppModel;
    public list<Applicable_Model__c> listAppModel;
    
    public YODA_AddProductstoKnowledgeCtlr(){
        setAppModel = new set<string>();
        listAppModel = new list<Applicable_Model__c>();
        search = '';
        //listWrapper = new list<wrapperAppModel>();
        mapWrapper = new map<string, wrapperAppModel>();
        knowledgeId = ApexPages.CurrentPage().getparameters().get('id');
        for(Applicable_Model__c am : [select Product__c from Applicable_Model__c where Knowledge__c = :knowledgeId]){
            setAppModel.add(am.Product__c);
        }
        for(Product2 p : [Select Id, Name, ProductCode, Category__r.Name from Product2 where Id not in :setappModel Limit 1000]){
            //listWrapper.add(new wrapperAppModel(false, p));
            mapWrapper.put(p.Id, new wrapperAppModel(false, p));
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
    
    public void search(){
        mapWrapper = new map<string, wrapperAppModel>();
        if(search == '' || search == null){
            for(Product2 p : [Select Id, Name, ProductCode, Category__r.Name from Product2 where Id not in :setappModel Limit 1000]){
            //listWrapper.add(new wrapperAppModel(false, p));
            mapWrapper.put(p.Id, new wrapperAppModel(false, p));
            }
        }
        else{
            string inpSearch = '%'+search+'%';
            for(Product2 p : [Select Id, Name, ProductCode, Category__r.Name from Product2 where Id not in :setappModel and (Name like :inpSearch or ProductCode like :inpSearch or Category__r.Name like :inpSearch) Limit 1000]){
            //listWrapper.add(new wrapperAppModel(false, p));
            mapWrapper.put(p.Id, new wrapperAppModel(false, p));
            }
        }
    }
    
    public pagereference Submit(){
        for(string wam : mapWrapper.keySet()){
            if(mapWrapper.get(wam).isSelected == true){
                Applicable_Model__c am = new Applicable_Model__c();
                am.Knowledge__c = knowledgeId;
                am.Product__c = mapWrapper.get(wam).product.Id;
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