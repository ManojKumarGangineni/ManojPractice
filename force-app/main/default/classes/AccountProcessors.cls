public class AccountProcessors {
        public static void initAccountList() {
                List<Account> myList = [Select Id, Name from Account Where Id in ('0017F00002r9rwzQAA','0017F00001q4AUyQAM')];
                List<Id> lstOfAccountIds = new List<Id>(); 
                for (Account acclst : mylist){ 
                    lstOfAccountIds.add(acclst.id);
                }     
                countContacts(lstOfAccountIds); 
            
        }
        @future
     public static void countContacts(list<Id> recordIds){
             List<Integer> ResultList = new List<Integer>();     
             Account[] AccountResultList = new List<Account>();  
            AggregateResult[] groupedResults = [Select count(Id) , 
                                                AccountId from contact 
                                                where AccountId in :recordIds group by AccountId]; // Aggregierte Liste mit Anzahl der Kontakte und der AccountID
        
          for (AggregateResult ar : groupedResults)  { 
         Integer currentNoOfContacts =  Integer.ValueOf(ar.get('expr0'))*1; 
        String currentAccountId = String.ValueOf(ar.get('AccountId')); 
        System.debug('AccountId: ' + currentAccountId); // Aktuelle AccountID ausgeben
         System.debug('Number of contacts: ' + currentNoOfContacts); 
        ResultList.add(currentNoOfContacts);
         Account a = new Account(Id=currentAccountId,Number_Of_Contacts__c=currentNoOfContacts); 
        
                    AccountResultList.add(a);
        
                }
        
            System.debug('ResultList'+ResultList);
        System.debug('AccountResultList'+AccountResultList);
        
                try {
        
                    update AccountResultList;        
        
                } catch(DmlException e) {
        
                    System.debug('An unexpected error has occurred: ' + e.getMessage());
        
                }
        
            }
     
}