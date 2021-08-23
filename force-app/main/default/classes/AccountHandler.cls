public class AccountHandler {
    public static void insertAccount(Integer noOfAccounts){
        list<Account> addAccounts = new list<Account>();
        Integer n = 1;
           while (n <= noOfAccounts) {
              Account a = new Account();
               a.Name = 'Acme Inc'+ n;
               a.AccountNumber = 'A000'+n;
             addAccounts.add(a);
               n++;
            }

        insert addAccounts;
                system.debug('addAccounts'+addAccounts);
        
    }
}