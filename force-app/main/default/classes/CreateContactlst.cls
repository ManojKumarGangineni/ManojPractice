public class CreateContactlst {
@AuraEnabled
        public static list<contact> getContactlst(String accountId)
        {
            list<contact> conlst = new list<contact>();
            conlst = [select id,LastName,FirstName,Email,Phone from contact where Email!=null and AccountId=:accountId];
            return conlst;
        }
    
}