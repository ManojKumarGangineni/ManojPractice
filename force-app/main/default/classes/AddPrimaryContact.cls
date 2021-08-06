public class AddPrimaryContact implements Queueable{
    
    public contact con;
    public String state;
     
   /* create a new constructor */
    public AddPrimaryContact(Contact c, String state){
        this.con = c;
        this.state = state;
    }
    /* Queuable Class  */
    public void execute(QueueableContext qc){
        list<contact> conlstadd = new list<contact>();
      list<Account> acclst = [select id,name,(select id,LastName from contacts) from account where BillingState = :state LIMIT 200]; 
        for(Account a: acclst) 
        {
            Contact con = con.clone(false,false,false,false);
            conlstadd.add(con);
        }
        insert conlstadd;
    }

}