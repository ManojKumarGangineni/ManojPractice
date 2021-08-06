@isTest
public class AccountProcessorTest {

    public static testmethod void TestAccountProcessorTest() {
        Account a = new Account();
        a.Name = 'ManojAccountTestt';
        Insert a;
        Contact c = new contact();
       c.LastName = 'CLastName';
        Insert c;
        set<id> setAccId = new set<Id>();
        setAccId.add(a.Id);
        test.startTest();
        AccountProcessor.countContacts(setAccId);
        test.stopTest();
    }

}