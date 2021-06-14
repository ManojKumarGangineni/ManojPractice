/* Name: RateTriggerHandler
Description : Trigger Handler for Rate Object
This class is running in without sharing mode since dealer can perform via advance search

Author : Tavant
History :
VERSION      AUTHOR            DATE                 DETAIL                                    UserStory/Req#
1.0 -       Tavant          28/SEP/2018          INITIAL DEVELOPMENT
*/
public with sharing class Twod_RateTriggerHandler extends TriggerHandler {
    
    private List<String> fieldsToBeTraced = new List<String>();
    private List<WOD_2__Rates_Details__c> newRateDetails;
    private List<WOD_2__Rates_Details__c> oldRateDetails;
    private List<Rate_Detail_Configuration__mdt> customMetadataRecs ;
    private static Set<String> dealerGroupIdSet ;
    private static Set<String> productGroupSet ;
    private Map<Id, WOD_2__Rates_Details__c> rateDetailsNewMap;
    private Map<Id, WOD_2__Rates_Details__c> rateDetailsOldMap;
    private List<WOD_2__Rates_Details__c> filteredNewRateDetails;
    private Map<String, List<WOD_2__Rates_Details__c>> currentProcessingRecords ;
    private Map<String, List<WOD_2__Rates_Details__c> > existingRateDetailsMap ;
    private Map<Id, WOD_2__Rates_Details__c> oldShopRatesMap ;
    private static Map<Id, WOD_2__Rates_Details__c> updatedShopRatesMap = new Map<Id, WOD_2__Rates_Details__c>();
    private static Boolean isJobAlreadyStarted = false;
    public static Map<String, List<String>> groupWithGroupMemMap;
    public static Map<String, List<String>> prdGroupWithGrpMemMap;
    public static Map<String, Id> dealerProdLineMap;
    
    private static final String KEY_SEPERATOR = ':';
    
    public Twod_RateTriggerHandler() {
        this.rateDetailsNewMap = (Map<Id, WOD_2__Rates_Details__c>)Trigger.newMap;
        this.rateDetailsOldMap = (Map<Id, WOD_2__Rates_Details__c>)Trigger.oldMap;
        this.newRateDetails = (List<WOD_2__Rates_Details__c>)Trigger.new;
        this.oldRateDetails = (List<WOD_2__Rates_Details__c>)Trigger.old;
        filteredNewRateDetails = new List<WOD_2__Rates_Details__c>();
        customMetadataRecs = new List<Rate_Detail_Configuration__mdt>();
        dealerGroupIdSet = new Set<String>();
        productGroupSet = new Set<String>();
        oldShopRatesMap = new Map<Id, WOD_2__Rates_Details__c>();
        existingRateDetailsMap = new Map<String, List<WOD_2__Rates_Details__c> >();
        currentProcessingRecords = new Map<String, List<WOD_2__Rates_Details__c>>();
        prdGroupWithGrpMemMap = new Map<String, List<String>>();
        initializeRequireddata();
    }
    
    public override void beforeInsert() {
        initializeExistingRateDetails();
        initializeData();
        if(filteredNewRateDetails != null && filteredNewRateDetails.size() > 0) {
            initializeExistingRateDetailsWithGroup(existingRateDetailsMap);
            initializeExistingRateDetailsWithGroup(currentProcessingRecords);
            initializeExistingRateDetailsWithProductGrp(existingRateDetailsMap);
            initializeExistingRateDetailsWithProductGrp(currentProcessingRecords);
            validateAllProcessingRecords();
            validateWithExistingRateRecords();
        }
    }
    
    public override void afterInsert(){
        onInsertRateDetails();
    } 
    
    public override void beforeDelete() {
        // To delete all the warranty rates which are associated with shop rate(deleted)
        List<WOD_2__Rates_Details__c> warrantyRateList = [SELECT Id, Name FROM WOD_2__Rates_Details__c WHERE Shop_Rate__c IN : rateDetailsOldMap.keySet()];
        if(warrantyRateList.size() > 0) {
            try {
                Delete warrantyRateList;    
            }
            catch(Exception ex) {
            }         
        }
    }
    
    public override void beforeUpdate() {
        initializeExistingRateDetails();
        initializeData();
        if(filteredNewRateDetails != null && filteredNewRateDetails.size() > 0) {
            initializeExistingRateDetailsWithGroup(existingRateDetailsMap);
            initializeExistingRateDetailsWithGroup(currentProcessingRecords);
            initializeExistingRateDetailsWithProductGrp(existingRateDetailsMap);
            initializeExistingRateDetailsWithProductGrp(currentProcessingRecords);
            validateAllProcessingRecords();
            validateWithExistingRateRecords();
        }
    }
    
    public override void afterUpdate(){
        onUpdateRateDetails();
        if(updatedShopRatesMap != null && !updatedShopRatesMap.isEmpty() && updatedShopRatesMap.size() > 0 && !isJobAlreadyStarted) {
            // Calling a Queueable Apex
            Twod_WarrantyRateCalcQueueable warrantyRateQueue = new Twod_WarrantyRateCalcQueueable(updatedShopRatesMap, 'Twod_RateTriggerHandler', null);
            ID warrantyRateJobId = System.enqueueJob(warrantyRateQueue);
            isJobAlreadyStarted = true;
        }
    }
    
    // To get required custom metadata records
    public void initializeRequireddata() {
        customMetadataRecs = [SELECT Id, Field_API_Name__c, Object_API_Name__c, Trace__c FROM Rate_Detail_Configuration__mdt WHERE Object_API_Name__c = 'WOD_2__Rates_Details__c'];
        for(Rate_Detail_Configuration__mdt metadataRec : customMetadataRecs) {
            if(String.isNotBlank(metadataRec.Field_API_Name__c) && metadataRec.Trace__c)
                fieldsToBeTraced.add(metadataRec.Field_API_Name__c);
        }
    }
    
    public void initializeData() {
        List<WOD_2__Rates_Details__c> rateDetailsToConsider = new List<WOD_2__Rates_Details__c>();
        if(Trigger.isInsert) 
            rateDetailsToConsider.addAll(newRateDetails);
        
        if(Trigger.isUpdate)
            rateDetailsToConsider.addAll(rateDetailsNewMap.values());
        
        // Extract productline and Dealer from all new shop rates
        Set<String> accountIdSet = new Set<String>();
        Set<String> productIdSet = new Set<String>();
        for(WOD_2__Rates_Details__c rateDetail : rateDetailsToConsider) {
            if('Shop Rate'.equalsIgnoreCase(rateDetail.WOD_2__Rate_Type__c)) {
                if(rateDetail.Dealer_Group__c != null)
                    dealerGroupIdSet.add(rateDetail.Dealer_Group__c);
                if(rateDetail.Warranty_Product_Group__c != null) 
                    productGroupSet.add(rateDetail.Warranty_Product_Group__c);
                if(rateDetail.WOD_2__Dealer__c != null)
                    accountIdSet.add(rateDetail.WOD_2__Dealer__c);
                if(rateDetail.Warranty_Product__c != null)
                    productIdSet.add(rateDetail.Warranty_Product__c);
            }
        }
        Map<Id, WOD_2__Group__c> groupMap ;
        if((dealerGroupIdSet != null && dealerGroupIdSet.size() > 0) || (productGroupSet != null && productGroupSet.size() > 0)) {
            groupMap = new  Map<Id, WOD_2__Group__c>([SELECT Id, Name, WOD_2__Object_Name__c, WOD_2__Name__c, (SELECT Id, Name, WOD_2__Account__c,WOD_2__Account__r.Name, WOD_2__Group__c, WOD_2__Warranty_Product__c, WOD_2__Warranty_Product__r.Name FROM WOD_2__Group_Members__r) FROM WOD_2__Group__c WHERE (ID IN : productGroupSet OR ID IN : dealerGroupIdSet) AND WOD_2__Object_Name__c IN ('Account','WOD_2__Warranty_Product__c')]);    
            for(Id groupId : groupMap.Keyset()) {
                List<WOD_2__Group_Member__c> groupMemberList = groupMap.get(groupId).WOD_2__Group_Members__r;
                for(WOD_2__Group_Member__c grpMem : groupMemberList) {
                    if(grpMem.WOD_2__Account__c != null){
                        accountIdSet.add(String.valueOf(grpMem.WOD_2__Account__c));
                    }
                    else {
                        productIdSet.add(String.valueOf(grpMem.WOD_2__Warranty_Product__c));
                    }
                }
            }
        }
        // To fetch all the dealer product lines associations
        Map<Id, Warranty_Customer_Product__c> dealerProductLineMap = new Map<Id, Warranty_Customer_Product__c>([SELECT Id, Name, Dealer__c, Manual_Review_Claims__c, Product_Line__c FROM Warranty_Customer_Product__c WHERE Dealer__c IN :accountIdSet AND Product_Line__c IN : productIdSet]);
        dealerProdLineMap = new Map<String, Id>();
        for(Warranty_Customer_Product__c associationRec : dealerProductLineMap.values()) {
            String combinedKey = associationRec.Dealer__c +'_' +associationRec.Product_Line__c ;
            dealerProdLineMap.put(combinedKey, associationRec.Id);
        }
        // Filter all the shop rates based on Warranty Customer Product
        for(WOD_2__Rates_Details__c shopRate : rateDetailsToConsider) {
            if('Shop Rate'.equalsIgnoreCase(shopRate.WOD_2__Rate_Type__c)) {
                Boolean rateToConsider = true;
                if(shopRate.WOD_2__Dealer__c != null && shopRate.Warranty_Product__c != null){ // Account and Product
                    String combinedKey = shopRate.WOD_2__Dealer__c + '_' + shopRate.Warranty_Product__c;
                    if(!dealerProdLineMap.containsKey(combinedKey)) {
                        shopRate.addError(Label.Twod_dealer_with_product_line_error);
                        rateToConsider = false;
                    }
                } 
                
                if(shopRate.WOD_2__Dealer__c != null && shopRate.Warranty_Product_Group__c != null && groupMap != null && groupMap.containsKey(shopRate.Warranty_Product_Group__c)){ // Account and Product Group
                    List<WOD_2__Group_Member__c> groupMemberList = groupMap.get(shopRate.Warranty_Product_Group__c).WOD_2__Group_Members__r;
                    String errMsg = Label.Twod_Dealer_with_product_group_error;
                    for(WOD_2__Group_Member__c prodMem : groupMemberList){
                        String combinedKey = shopRate.WOD_2__Dealer__c + '_' + prodMem.WOD_2__Warranty_Product__c;
                        if(!dealerProdLineMap.containsKey(combinedKey)) {
                            errMsg += prodMem.WOD_2__Warranty_Product__r.Name + ', ';
                            rateToConsider = false;
                        }
                    }
                    if(!rateToConsider)
                        shopRate.addError(errMsg.removeEnd(', '));
                }
                if(shopRate.Dealer_Group__c != null && shopRate.Warranty_Product__c != null && groupMap != null && groupMap.containsKey(shopRate.Dealer_Group__c)) { // Account Group and Product
                    List<WOD_2__Group_Member__c> groupMemberList = groupMap.get(shopRate.Dealer_Group__c).WOD_2__Group_Members__r;
                    String errMsg =  Label.Twod_Dealer_Group_with_Product_Error;
                    for(WOD_2__Group_Member__c accMem : groupMemberList){
                        String combinedKey = accMem.WOD_2__Account__c + '_' + shopRate.Warranty_Product__c;
                        if(!dealerProdLineMap.containsKey(combinedKey)) {
                            errMsg += accMem.WOD_2__Account__r.Name + ', ';
                            rateToConsider = false;
                        }
                    }
                    if(!rateToConsider)
                        shopRate.addError(errMsg.removeEnd(', '));
                }
                if(shopRate.Dealer_Group__c != null && shopRate.Warranty_Product_Group__c != null) { // Account Group and Product Group
                    String errMsg = Label.Twod_WCP_Groups_Error;
                    // One or more dealers from the selected Dealer group do not deal with one or more product lines from the selected product line group.
                    List<WOD_2__Group_Member__c> dlrGrpMemList = groupMap != null && groupMap.containsKey(shopRate.Dealer_Group__c) ? groupMap.get(shopRate.Dealer_Group__c).WOD_2__Group_Members__r : null;
                    List<WOD_2__Group_Member__c> prdGrpMemList = groupMap != null && groupMap.containsKey(shopRate.Warranty_Product_Group__c) ? groupMap.get(shopRate.Warranty_Product_Group__c).WOD_2__Group_Members__r : null;
                    if(dlrGrpMemList != null && prdGrpMemList != null) {
                        for(WOD_2__Group_Member__c accMem : dlrGrpMemList) {
                            for(WOD_2__Group_Member__c prodMem : prdGrpMemList) {
                                String combinedKey = accMem.WOD_2__Account__c + '_' + prodMem.WOD_2__Warranty_Product__c;
                                if(!dealerProdLineMap.containsKey(combinedKey)) {
                                    rateToConsider = false;
                                }
                            }
                        }    
                    }
                    if(!rateToConsider)
                        shopRate.addError(errMsg.removeEnd(', '));
                }
                
                if(rateToConsider) {
                    filteredNewRateDetails.add(shopRate);
                    // To check list of fields value changes
                    if(shopRate.Id != null && fieldsToBeTraced.size() > 0) {
                        for(String str : fieldsToBeTraced) {
                            if(shopRate.get(str) != rateDetailsOldMap.get(shopRate.Id).get(str)) {
                                updatedShopRatesMap.put(shopRate.Id, shopRate);
                                oldShopRatesMap.put(shopRate.Id,rateDetailsOldMap.get(shopRate.Id));
                            }
                        }
                    }
                    String key = keyGenerator(shopRate);
                    if(currentProcessingRecords.containsKey(key))
                        currentProcessingRecords.get(key).add(shopRate);
                    else
                        currentProcessingRecords.put(key, new List<WOD_2__Rates_Details__c>{shopRate});
                }
            }
        }
    }
    
    public String keyGenerator(WOD_2__Rates_Details__c newRate) {
        String key = '';
        key += newRate.WOD_2__Dealer__c != null ? newRate.WOD_2__Dealer__c + KEY_SEPERATOR : '';
        key += newRate.Dealer_Group__c != null ? newRate.Dealer_Group__c + KEY_SEPERATOR : '';
        key += newRate.Warranty_Product__c != null ? newRate.Warranty_Product__c + KEY_SEPERATOR : '';
        key += newRate.Warranty_Product_Group__c != null ? newRate.Warranty_Product_Group__c + KEY_SEPERATOR : '';
        key += newRate.Business_Category_Configuration__c != null ? newRate.Business_Category_Configuration__c : '';
        return key;
    }
    
    public void validateAllProcessingRecords() {
        // To validate date on all current processing rate detail records
        String errorMessage = Label.Twod_Invalid_Rate_Details;
        List<WOD_2__Rates_Details__c> rateDetailsToConsider = new List<WOD_2__Rates_Details__c>();
        if(Trigger.isInsert) {
            rateDetailsToConsider.addAll(filteredNewRateDetails);
        }
        if(Trigger.isUpdate)
            rateDetailsToConsider.addAll(rateDetailsNewMap.values());
        
        for(WOD_2__Rates_Details__c newRate : rateDetailsToConsider) {
            if('Shop Rate'.equalsIgnoreCase(newRate.WOD_2__Rate_Type__c) && (('Active'.equalsIgnoreCase(newRate.WOD_2__Status__c) && newRate.Migrated_Data__c) || !newRate.Migrated_Data__c)) {
                String key = keyGenerator(newRate);
                if(currentProcessingRecords.containsKey(key)) { 
                    for(WOD_2__Rates_Details__c rateDetail : currentProcessingRecords.get(key)) {
                        if((rateDetail.Id != null && newRate.Id != null && rateDetail.Id != newRate.Id) || (newRate.Id == null && rateDetail.Id != null)) { // To skip the current processing record
                            if(rateDetail.WOD_2__Active_From__c <= newRate.WOD_2__Active_From__c
                               && newRate.WOD_2__Active_From__c <= rateDetail.WOD_2__Active_Until__c) {
                                   newRate.addError(errorMessage); // + '----one'
                                   break;
                               }
                            //Validate 'Active Until'
                            if(rateDetail.WOD_2__Active_From__c <= newRate.WOD_2__Active_Until__c
                               && newRate.WOD_2__Active_Until__c <= rateDetail.WOD_2__Active_Until__c) {
                                   newRate.addError(errorMessage); // + '----two'
                                   break;
                               }
                            if(newRate.WOD_2__Active_From__c <= rateDetail.WOD_2__Active_From__c
                               && newRate.WOD_2__Active_Until__c >= rateDetail.WOD_2__Active_Until__c) {
                                   newRate.addError(errorMessage); // + '----three'
                                   break;   
                               }
                        }
                    }
                }
            }
        }
    }
    
    public void initializeExistingRateDetails() {
        List<WOD_2__Rates_Details__c> existingActiveRateDeatils = new List<WOD_2__Rates_Details__c>();
        Set<String> incomingAccountIdSet = new Set<String>();
        Set<String> productIdSet = new Set<String>();
        for(WOD_2__Rates_Details__c rateDt : newRateDetails) { // Extract existing shop rates based on insert/update shop rate
            if('Shop Rate'.equalsIgnoreCase(rateDt.WOD_2__Rate_Type__c)) {
                if(rateDt.Dealer_Group__c != null)
                    dealerGroupIdSet.add(rateDt.Dealer_Group__c);
                if(rateDt.Warranty_Product_Group__c != null) 
                    productGroupSet.add(rateDt.Warranty_Product_Group__c);
                if(rateDt.WOD_2__Dealer__c != null)
                    incomingAccountIdSet.add(rateDt.WOD_2__Dealer__c);
                if(rateDt.Warranty_Product__c != null)
                    productIdSet.add(rateDt.Warranty_Product__c);
            }
        }
        
        List<WOD_2__Group_Member__c> grpMemList = new List<WOD_2__Group_Member__c>();
        grpMemList = [SELECT Id, Name, WOD_2__Account__c, WOD_2__Group__c, WOD_2__Warranty_Product__c FROM WOD_2__Group_Member__c WHERE 
                      (WOD_2__Account__c IN : incomingAccountIdSet OR WOD_2__Warranty_Product__c IN : productIdSet OR WOD_2__Group__c IN : productGroupSet OR WOD_2__Group__c IN : dealerGroupIdSet) AND WOD_2__Group__r.WOD_2__Object_Name__c IN ('Account','WOD_2__Warranty_Product__c')];
        Set<Id> accgroupIdSet = new Set<Id>();
        Set<Id> prodGroupIdSet = new Set<Id>();
        
        for(WOD_2__Group_Member__c grpMem : grpMemList) {
            if(grpMem.WOD_2__Account__c != null) {
                incomingAccountIdSet.add(grpMem.WOD_2__Account__c);
                accgroupIdSet.add(grpMem.WOD_2__Group__c);
            }
            if(grpMem.WOD_2__Warranty_Product__c != null) {
                prodGroupIdSet.add(grpMem.WOD_2__Group__c);
                productIdSet.add(grpMem.WOD_2__Warranty_Product__c);
            }
        }
        if(Trigger.isUpdate && Trigger.isBefore){
            existingActiveRateDeatils = [SELECT Id, Name, WOD_2__Active_From__c, WOD_2__Active_Until__c, WOD_2__Dealer__c, Dealer_Group__c, WOD_2__Dealer__r.Id, WOD_2__Dealer__r.Name,  Dealer_Group__r.Name, Warranty_Product__c, Warranty_Product_Group__c,Business_Category_Configuration__c FROM WOD_2__Rates_Details__c WHERE WOD_2__Active_From__c != NULL AND WOD_2__Rate_Type__c='Shop Rate' AND WOD_2__Active_Until__c != NULL AND WOD_2__Status__c = 'Active' AND Id NOT IN :rateDetailsNewMap.keySet() AND (WOD_2__Dealer__c IN : incomingAccountIdSet OR Dealer_Group__c IN : accgroupIdSet) AND ( Warranty_Product__c IN : productIdSet OR Warranty_Product_Group__c IN : prodGroupIdSet)]; // AND Id NOT IN:rateDetailsNewMap.keySet() // Need to cross check the Id filter in query
        } 
        if(Trigger.isBefore && Trigger.isInsert) {
            existingActiveRateDeatils = [SELECT Id, Name, WOD_2__Active_From__c, WOD_2__Active_Until__c, WOD_2__Dealer__c, Dealer_Group__c, WOD_2__Dealer__r.Id, WOD_2__Dealer__r.Name,  Dealer_Group__r.Name, Warranty_Product__c, Warranty_Product_Group__c,Business_Category_Configuration__c FROM WOD_2__Rates_Details__c WHERE WOD_2__Active_From__c != NULL AND WOD_2__Active_Until__c != NULL AND WOD_2__Status__c = 'Active' AND WOD_2__Rate_Type__c='Shop Rate' AND (WOD_2__Dealer__c IN : incomingAccountIdSet OR Dealer_Group__c IN : accgroupIdSet) AND ( Warranty_Product__c IN : productIdSet OR Warranty_Product_Group__c IN : prodGroupIdSet)];
        }
        for(WOD_2__Rates_Details__c rate : existingActiveRateDeatils) {
            String key = keyGenerator(rate);
            if(rate.Dealer_Group__c != null)
                dealerGroupIdSet.add(rate.Dealer_Group__c);
            if(rate.Warranty_Product_Group__c != null)
                productGroupSet.add(rate.Warranty_Product_Group__c);
            
            if(existingRateDetailsMap.containsKey(key))
                existingRateDetailsMap.get(key).add(rate);
            else
                existingRateDetailsMap.put(key, new List<WOD_2__Rates_Details__c>{rate});
        }
    }
    
    public void initializeExistingRateDetailsWithProductGrp(Map<String, List<WOD_2__Rates_Details__c> > rateDetailsMap) {
        List<WOD_2__Group_Member__c> prdctGrpMemList = [SELECT Id, Name, WOD_2__Warranty_Product__c,WOD_2__Warranty_Product__r.Name, WOD_2__Warranty_Product__r.Id, WOD_2__Group__c 
                                                        FROM WOD_2__Group_Member__c 
                                                        WHERE WOD_2__Group__c IN :productGroupSet AND WOD_2__Warranty_Product__c != null AND WOD_2__Group__r.WOD_2__Object_Name__c ='WOD_2__Warranty_Product__c'];
        for(WOD_2__Group_Member__c grpMem : prdctGrpMemList) {
            if(!prdGroupWithGrpMemMap.containsKey(grpMem.WOD_2__Group__c)) {
                prdGroupWithGrpMemMap.put(grpMem.WOD_2__Group__c, new List<String>{grpMem.WOD_2__Warranty_Product__c});
            }
            else {
                prdGroupWithGrpMemMap.get(grpMem.WOD_2__Group__c).add(grpMem.WOD_2__Warranty_Product__c);
            }
        }
        // To populate group member with the product rate details
        for(String combinedKey : rateDetailsMap.keySet()) {
            List<String> splittedKey = combinedKey.split(KEY_SEPERATOR);
            String extractedPrdGroupId = '';
            if(!splittedKey.isEmpty() && splittedKey != null) {
                if(splittedKey.size() > 1 && productGroupSet.contains(splittedKey[1])) {
                    extractedPrdGroupId = splittedKey[1];
                }
            }
            
            if(prdGroupWithGrpMemMap != null && prdGroupWithGrpMemMap.containsKey(extractedPrdGroupId) && rateDetailsMap.containsKey(combinedKey)) {
                List<WOD_2__Rates_Details__c> accountGroupRateDetails = new List<WOD_2__Rates_Details__c>();
                accountGroupRateDetails.addAll(rateDetailsMap.get(combinedKey));
                List<String> groupMemberList = new List<String>();
                groupMemberList = prdGroupWithGrpMemMap.get(extractedPrdGroupId);
                for(String groupMem : groupMemberList) { // All groupmembers with respect to the product group
                    for(WOD_2__Rates_Details__c rateDetail : accountGroupRateDetails) { // Assign rate detail to each group member (Product)
                        String newlyFormedKey = '';
                        newlyFormedKey += rateDetail.WOD_2__Dealer__c != null ? rateDetail.WOD_2__Dealer__c + KEY_SEPERATOR : '';
                        newlyFormedKey += groupMem + KEY_SEPERATOR ;
                        newlyFormedKey += rateDetail.Business_Category_Configuration__c != null ? rateDetail.Business_Category_Configuration__c : '';
                        if(rateDetailsMap.containsKey(newlyFormedKey))
                            rateDetailsMap.get(newlyFormedKey).add(rateDetail);
                        else
                            rateDetailsMap.put(newlyFormedKey, new List<WOD_2__Rates_Details__c> {rateDetail});
                    }
                }
            }
        }
    }
    
    public void initializeExistingRateDetailsWithGroup(Map<String, List<WOD_2__Rates_Details__c> > rateDetailsMap) {
        List<WOD_2__Group_Member__c> groupMembersList = [SELECT Id, Name, WOD_2__Account__c,WOD_2__Account__r.Name, WOD_2__Account__r.Id, WOD_2__Group__c 
                                                         FROM WOD_2__Group_Member__c 
                                                         WHERE WOD_2__Group__c IN :dealerGroupIdSet AND WOD_2__Account__c != null AND WOD_2__Group__r.WOD_2__Object_Name__c IN ('Account')];
        groupWithGroupMemMap = new Map<String, List<String>>();
        for(WOD_2__Group_Member__c gm : groupMembersList) { // segregating group members with the group
            if(!groupWithGroupMemMap.containsKey(gm.WOD_2__Group__c)) {
                groupWithGroupMemMap.put(gm.WOD_2__Group__c, new List<String>{gm.WOD_2__Account__c});
            }
            else {
                groupWithGroupMemMap.get(gm.WOD_2__Group__c).add(gm.WOD_2__Account__c);
            }
        }       
        // To populate group member with the group rate details
        for(String combinedKey : rateDetailsMap.keySet()) {
            List<String> splittedKey = combinedKey.split(KEY_SEPERATOR);
            String extractedGroupId = '';
            if(!splittedKey.isEmpty() && splittedKey != null) {
                if(splittedKey.size() > 0 && dealerGroupIdSet.contains(splittedKey[0])) {
                    extractedGroupId = splittedKey[0];
                }
                if(splittedKey.size() > 1 && dealerGroupIdSet.contains(splittedKey[1])) {
                    extractedGroupId = splittedKey[1];
                }
            }
            
            if(groupWithGroupMemMap != null && groupWithGroupMemMap.containsKey(extractedGroupId) && rateDetailsMap.containsKey(combinedKey)) {
                List<WOD_2__Rates_Details__c> accountGroupRateDetails = new List<WOD_2__Rates_Details__c>();
                accountGroupRateDetails.addAll(rateDetailsMap.get(combinedKey));
                List<String> groupMemberList = new List<String>();
                groupMemberList = groupWithGroupMemMap.get(extractedGroupId);
                for(String groupMem : groupMemberList) { // All groupmembers with respect to the account group
                    for(WOD_2__Rates_Details__c rateDetail : accountGroupRateDetails) { // Assign rate detail to each group member(Account)
                        String newlyFormedKey = '';
                        newlyFormedKey += groupMem + KEY_SEPERATOR ;
                        newlyFormedKey += rateDetail.Warranty_Product__c != null ? rateDetail.Warranty_Product__c + KEY_SEPERATOR : '';
                        newlyFormedKey += rateDetail.Warranty_Product_Group__c != null ? rateDetail.Warranty_Product_Group__c + KEY_SEPERATOR : '';
                        newlyFormedKey += rateDetail.Business_Category_Configuration__c != null ? rateDetail.Business_Category_Configuration__c : '';
                        
                        if(rateDetailsMap.containsKey(newlyFormedKey))
                            rateDetailsMap.get(newlyFormedKey).add(rateDetail);
                        else
                            rateDetailsMap.put(newlyFormedKey, new List<WOD_2__Rates_Details__c> {rateDetail});
                    }
                }
            }
        }
    }
    
    public void validateWithExistingRateRecords() {
        // validating new rate records with the existing rate records.
        String errorMessage = Label.Twod_Invalid_Rate_Details;
        for(WOD_2__Rates_Details__c objNewRate : filteredNewRateDetails) {
            if('Shop Rate'.equalsIgnoreCase(objNewRate.WOD_2__Rate_Type__c) && (('Active'.equalsIgnoreCase(objNewRate.WOD_2__Status__c) && objNewRate.Migrated_Data__c) || !objNewRate.Migrated_Data__c)) {
                List<String> keysToConsider = Twod_RateDetailUtility.prepareCombinationKeysForSR(objNewRate, prdGroupWithGrpMemMap, groupWithGroupMemMap);
                for(String key : keysToConsider) {
                    List<WOD_2__Rates_Details__c> existingRateDetails = new List<WOD_2__Rates_Details__c>();
                    if(existingRateDetailsMap.containsKey(key)) { // Checking with existing dealer group members
                        existingRateDetails.addAll(existingRateDetailsMap.get(key));
                    }
                    for(WOD_2__Rates_Details__c objExistingRate : existingRateDetails) {
                        if((objExistingRate.Id != null && objNewRate.Id != null && objExistingRate.Id != objNewRate.Id) || ( objNewRate.Id == null)) { // To skip the current processing record
                            //Validate 'Active From'
                            if(objExistingRate.WOD_2__Active_From__c <= objNewRate.WOD_2__Active_From__c
                               && objNewRate.WOD_2__Active_From__c <= objExistingRate.WOD_2__Active_Until__c) {
                                   objNewRate.addError(errorMessage); // + '----- 1'
                                   break;
                               }
                            //Validate 'Active Until'
                            if(objExistingRate.WOD_2__Active_From__c <= objNewRate.WOD_2__Active_Until__c
                               && objNewRate.WOD_2__Active_Until__c <= objExistingRate.WOD_2__Active_Until__c) {
                                   objNewRate.addError(errorMessage); // + '----- 2'
                                   break;
                               }
                            if(objNewRate.WOD_2__Active_From__c <= objExistingRate.WOD_2__Active_From__c
                               && objNewRate.WOD_2__Active_Until__c >= objExistingRate.WOD_2__Active_Until__c) {
                                   objNewRate.addError(errorMessage); // + '----- 3'
                                   break;   
                               }
                        }
                    }
                }
            }
        }
    }
    
    private void onInsertRateDetails(){
        Set<Id> rateDetailIdSet = new Set<Id>();
        for(WOD_2__Rates_Details__c rateDetail : newRateDetails) { // newRateDetails
            if((rateDetail.WOD_2__Dealer__c != null || rateDetail.Dealer_Group__c != null) && rateDetail.WOD_2__Status__c == 'Active') {
                rateDetailIdSet.add(rateDetail.id);
            }
        }
        if(!rateDetailIdSet.isEmpty()) {
            Twod_WithoutSharingClass.rateDetailAccountSharing(rateDetailIdSet, groupWithGroupMemMap);
        }
    }
    
    private void onUpdateRateDetails(){
        Set<Id> toBeUpdateRateDetailSet = new Set<Id>();
        Set<String> sharingRecToBeDeleted = new Set<String>();
        for(integer i = 0; i < oldRateDetails.size(); i++ ) {
            WOD_2__Rates_Details__c oldRate = oldRateDetails[i];
            WOD_2__Rates_Details__c newRate =  rateDetailsNewMap.get(oldRateDetails[i].Id);
            if(((newRate.WOD_2__Dealer__c != null && oldRate.WOD_2__Dealer__c != newRate.WOD_2__Dealer__c)
                ||  (newRate.Dealer_Group__c != null && oldRate.Dealer_Group__c != newRate.Dealer_Group__c)) || (newRate.WOD_2__Status__c == 'Active')) {//check if dealer has changed, if changed then insert new rate detail share
                    toBeUpdateRateDetailSet.add(newRate.id);
                    sharingRecToBeDeleted.add(oldRate.Id);
                }
            if(newRate.WOD_2__Status__c != 'Active') { // To delete the sharing whenever shop rate is inactive / Draft.
                sharingRecToBeDeleted.add(newRate.Id); 
            }
        }
        // To delete existing sharing records
        if(sharingRecToBeDeleted != null && sharingRecToBeDeleted.size() > 0) {
            Twod_WithoutSharingClass.deleteRateSharing(sharingRecToBeDeleted);
            
        }
        if(!toBeUpdateRateDetailSet.isEmpty()) {
            Twod_WithoutSharingClass.rateDetailAccountSharing(toBeUpdateRateDetailSet, groupWithGroupMemMap);
        }
    } 
}