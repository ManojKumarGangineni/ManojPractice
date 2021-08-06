public class AccountProcessor {
@future
    Public static void countContacts(set<Id> lstOfAccIds)
    {
        //List<id> lstOfAccIds = new list<Id>();
        List<Account> acc = [select id,Name,Number_of_Contacts__c,(select id from contacts) from account where Id in:lstOfAccIds];
       for(Account accTemp : acc)
        {
            List<Contact> lstcontacts =accTemp.contacts;
            system.debug('lstContacts'+lstcontacts);
            accTemp.Number_of_Contacts__c = lstcontacts.size();
        }

        update acc;
    }
}