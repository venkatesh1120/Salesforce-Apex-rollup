public class helperclassroll {
    
    public static list<Contact> newlist = new list<Contact>();
    public static list<Contact> oldlist = new list<Contact>();
    
    public static void afterInsertOperation() {
        collectids(new List<Contact>(), newlist);
    }
    public static void afterUpdateOperation() {
        collectids(oldlist, newlist);
    }
    
    public static void afterUndeleteOperation() {
        collectids(new List<Contact>(), newlist);
    }
    
    public static void afterDeleteOperation() {
        collectids(oldlist, new List<Contact>());
    }
    public static void collectids(list<Contact>oldlist , list<Contact> newlist){
        set<id> listofids = new set<id>();
        for(Contact a :newlist){
            listofids.add(a.AccountId);
        }
        for(Contact b :oldlist){
            listofids.add(b.AccountId);
        }
        listofids.remove(Null);
        if(listofids.Size() > 0 ){
            methodsum(listofids);
        }
    }
    public static void methodsum(set<Id> listofids){
        
        //List<Contact> count = [SELECT AccountId, price__c From Contact WHERE AccountId=:listofids];
        iF(listofids.size() > 0){
            list<Account> acc = [SELECT id, total_related_amount__c,Opportunity__c,(SELECT id, price__c From Contacts)
                                 FROM ACCOUNT WHERE id=:listofids];
            
            
            Decimal amount =0;
            for(Account v : acc){
                
                for(Contact v2 : v.Contacts){
                    amount +=  (v2.price__c!=NULL?v2.price__c :0 );
                    
                    
                }
                v.total_related_amount__c =amount;
            }
            if(acc.size() > 0) {
                update acc;
                
            } 
            set<Id> ids2 =new set<Id>();
            for(Account a :acc ){
                ids2.add(a.Opportunity__c);
            }
            list<Opportunity> opp = [SELECT id, total_on_account__c,Price_Book__c,(SELECT id,total_related_amount__c FROM Accounts__r ) 
                                     FROM Opportunity  WHERE id=:ids2];
            Decimal amountforOpp =0;
            for(Opportunity v : opp){
                for(Account v2 : v.Accounts__r){
                    amountforOpp +=  (v2.total_related_amount__c!=NULL?v2.total_related_amount__c:0 );
                }
                system.debug('opp:' +opp);
                v.total_on_account__c  =amountforOpp;
            }
            
            if(opp.size() > 0) {
                update opp;
            }
            Set<Id> idst = new  Set<Id>();
            for(Opportunity c:opp){
                idst.add(c.Price_Book__c);
            }
            idst.remove(null);
            list<Pricebook2> pricebook4 = [SELECT Id,pricebookA__c,(SELECT Id,total_on_account__c FROM Opportunities__r) FROM Pricebook2 WHERE id =:idst];
            decimal amountofprice= 0.0;
            
            for(Pricebook2 tes:pricebook4){
                for(Opportunity tes1:tes.Opportunities__r){
                    
                    amountofprice += (tes1.total_on_account__c!=null?tes1.total_on_account__c:0);
                    
                }
                tes.pricebookA__c=amountofprice;
            }
            if(pricebook4.size() > 0) {
                update pricebook4;
            }
        }
        
    }
}