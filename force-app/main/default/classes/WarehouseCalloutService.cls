public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    public static void execute(QueueableContext context){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            system.debug('JSON.deserializeUntyped'+JSON.deserializeUntyped(response.getBody()));
            List<Object> externalProducts = (List<Object>) JSON.deserializeUntyped(response.getBody());
            system.debug('externalProducts');
            List<Product2> newProduct = new list<Product2>();
            for(Object obj : externalProducts){
                Map<String, Object> productMap = (Map<String, Object>) obj;
                Product2 pr = new Product2();
                pr.Replacement_Part__c =  (Boolean)productMap.get('replacement');
                pr.Cost__c = (Integer)productMap.get('cost');
                pr.Current_Inventory__c = (Integer)productMap.get('quantity');
                pr.Lifespan_Months__c = (Integer)productMap.get('lifespan') ;
                pr.Maintenance_Cycle__c = (Integer)productMap.get('maintenanceperiod');
                pr.Warehouse_SKU__c = (String)productMap.get('sku');
                pr.ProductCode = (String)productMap.get('_id');
                pr.Name = (String)productMap.get('name');
                newProduct.add(pr);
            }
            if(newProduct.size()>0){
                upsert newProduct;
            }
        }
    }
    
}