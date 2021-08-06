public with Sharing  class CarTypeSearch {
@AuraEnabled
    public static list<Car_Types__c> getCarTypes()
    {
        return [select id,name from Car_Types__c];
    }
}