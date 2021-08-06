@Istest
public class AddPrimaryContactTest {
    public static testmethod void AddPrimaryContact()
    {
        list<Account> acclist = [select id,name,BillingState from Account ];
        for(integer i =0;i<=50;i++)
        {
            acclist.add(new Account(Name= 'test'+i,BillingState = 'CA'));
        }
        for(integer j =0;j<=50;j++)
        {
            acclist.add(new Account(Name= 'testNY'+j,BillingState = 'NY'));
        }
        insert acclist;
        Contact con = new contact();
            con.LastName = 'test';
        insert con;
        String State = 'NY';
        AddPrimaryContact addPrimaryCon = new AddPrimaryContact(con,State);
        test.startTest();
        System.enqueueJob(addPrimaryCon);
        test.stopTest();
    }
}