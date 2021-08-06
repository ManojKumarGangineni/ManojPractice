public class AccountUtility {
    public static void viewAnnualRevenue(){
        list<account> accountsList = new list<account>();
        accountsList = [select Name,AnnualRevenue from account];
        for(account accountTemp : accountsList){
            string acctRev = 'AccountName' + accountTemp.Name + ':'+ 'Annual Revenue'+ accountTemp.AnnualRevenue;
            system.debug('acctRev'+acctRev);
        }
        
    }
}