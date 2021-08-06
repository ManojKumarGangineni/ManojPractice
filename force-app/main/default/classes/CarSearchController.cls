public class CarSearchController {
     @AuraEnabled
          public static list<Car__c> getCars(string carTypeId)
    {
        if(carTypeId != null && carTypeId.equalsIgnoreCase(''))
           {
               return [SELECT Id, Name, Car_Type__c,Per_Day_Rent__c,Mileage__c,Geo_Location__longitude__s, Geo_Location__latitude__s, 
                       Picture__c, Contact__r.name,Build_Year__c FROM Car__c where Available_For_Rent__c = true];
           }
        else
        {
           return [SELECT Id, Name,Car_Type__c,Per_Day_Rent__c,Mileage__c, Geo_Location__longitude__s, Geo_Location__latitude__s, 
                       Picture__c, Contact__r.name,Build_Year__c FROM Car__c where 
                   Car_Type__c  =: carTypeId and Available_For_Rent__c = true]; 
        }
    }
    
}