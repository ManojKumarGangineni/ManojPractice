public class RandomContactFactory 
{
	public static List<Contact> generateRandomContacts(integer numofContacts,string LastNameGen)
    {
    	List<Contact> conlst= new List<Contact>();
    	for(Integer i=0;i<numofContacts;i++)
    	{
        	//LastNameGen='Test'+ i;
        	Contact a=new Contact(FirstName='Manoj'+i,LastName=LastNameGen);
            conlst.add(a);
        }
        return conlst;
    }
}