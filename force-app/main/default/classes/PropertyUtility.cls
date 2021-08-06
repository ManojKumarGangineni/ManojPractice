public class PropertyUtility {
    public static void newListedProperties(){
        list<Property__c> newPropList = new list<Property__c>();
        	newPropList = [select Name,Broker__r.Email__c,Days_On_Market__c from Property__c where Days_On_Market__c < 31];
        for(Property__c proLstTemp : newPropList){
            String propEmail = 'Property Name'+proLstTemp.Name+ ':' +'Broker Email'+proLstTemp.Broker__r.Email__c;
            //newPropList.add(proLstTemp);
            system.debug('propEmail'+propEmail);
        }
      
        system.debug('newPropList'+newPropList);
    }
}