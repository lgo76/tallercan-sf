/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-29-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class TallercanUtilsTest {
    static Product2 createMaterial(boolean stock){
        Product2 newProduct = new Product2();
        
        // Set the required fields
        newProduct.Name = 'material1';
        newProduct.ProductCode = 'MAT1-1';
        newProduct.IsActive = true;
        newProduct.Is_service__c = false;
        newProduct.Category__c = 'Standard';
        newProduct.Family = 'matCategory';
        newProduct.Stock__c = stock;
        return newProduct;
    }
    
    static Product2 createService(String materials){
        Product2 newProduct = new Product2();
        // Set the required fields
        newProduct.Name = 'service1';
        newProduct.ProductCode = 'SV1';
        newProduct.IsActive = true;
        newProduct.Is_service__c = true;
        newProduct.Required_materials__c = materials;
        return newProduct;
    }
    
    static List<OpportunityLineItem> createOppLineItems(Opportunity reception, List<Product2> products){
        
        Id standardPricebookId = Test.getStandardPricebookId();
               
        List<OpportunityLineItem> oliToInsert = new List<OpportunityLineItem>();
        OpportunityLineItem oli1 = null;
        List<PricebookEntry> pbentries = new List<PricebookEntry>();
        for(Product2 p: products){
            //Create PBEntries
            pbentries.add(new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = p.Id,
            UnitPrice = 100,
            IsActive = true));
        }
        insert pbentries;
        System.debug('PBENTRY: ' + [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry]);
        Map<Id, PricebookEntry> mapProductPricebook = getPBMap();
        System.debug('mapp: ' + mapProductPricebook);

                
        for(Product2 p : products){
            if(p.Is_Service__c){
                //Create OppLineItems
                oli1 = new OpportunityLineItem();
                oli1.PricebookEntryId = mapProductPricebook.get(p.Id).Id;
                oli1.Quantity = 1;
                oli1.opportunityId = reception.Id;
                oli1.product2id = p.Id;
                oli1.UnitPrice = mapProductPricebook.get(p.Id).UnitPrice * oli1.Quantity;
                oliToInsert.add(oli1);
            } 
        }
        insert oliToInsert;
        
        return oliToInsert;
    }
    
    static List<QuoteLineItem> createQuoteLineItems(List<Product2> prods, Quote q, Map<Id, PricebookEntry> ppbeMap){
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        for(Product2 p: prods){
            // Create a QuoteLineItem record
            qliList.add(new QuoteLineItem(
                QuoteId = q.Id,
                PricebookEntryId = ppbeMap.get(p.Id).Id,
                Quantity = 1,
                UnitPrice = 100
            ));
        }
        insert qliList;
        return qliList;
    }
    
    static Map<Id, PricebookEntry> getPBMap(){
        List<PricebookEntry> pbentriesinserted = [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry];
        Map<Id, PricebookEntry> mapProductPricebook = new Map<Id, PricebookEntry>();
        for(PricebookEntry pbe1:pbentriesinserted){
            mapProductPricebook.put(pbe1.Product2Id, pbe1);
        }
        return mapProductPricebook;
    }
    
    @testSetup
    static void setupTestData(){
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

        // Create Account
        Account acc = new Account();
        acc.LastName = 'Prueba';
        acc.FirstName = 'Account';
        acc.BillingStreet = 'Calle Inventada';
        acc.BillingCity = 'Santander';
        acc.BillingCountry = 'Spain';
        acc.Phone = '633445533';
        acc.PersonHomePhone = '942333333';
        acc.PersonEmail = 'prueba@prueba.com';
        acc.Document_Number__c = '76655443H';
        acc.RecordTypeId = personAccountRecordTypeId;
        insert acc;

        // Create Vehicle
        Vehicle__c v = new Vehicle__c();
        v.Name = 'Test1';
        v.Chasis_number__c = '465859845';
        v.DT_Car_Registration_Date__c = Date.today();
        v.DT_Next_ITV_Revision_Date__c = Date.today().addDays(40);
        v.PK_Fuel_Type__c = 'Fuel Oil';
        v.PK_Vehicle_Brand__c = 'BMW';
        v.PK_Vehicle_Model__c = '2 Series';
        v.TX_Car_Number_Plate__c = '4321HTT';
        v.LK_Vehicle_Owner__c = acc.Id;
        insert v;

        // Create reception
        Opportunity opp = new Opportunity();
        opp.Name = 'Opp Prueba';
        opp.Description = 'Prueba de oportunidad';
        opp.AccountId = acc.id;
        opp.Amount = 500;
        opp.CloseDate = Date.today().addDays(10);
        opp.StageName = 'Created';
        opp.LK_Vehicle__c = v.Id;
        insert opp;

        //Create materials and services
        Product2 serviceCreated = createService('matCategory');
        Product2 materialWithStock = createMaterial(false);
        //Create services and materials
        List<Product2> materialAndServiceList = new List<Product2>();
        materialAndServiceList.add(materialWithStock);
        materialAndServiceList.add(serviceCreated);
        insert materialAndServiceList;
        
        
    }
    
    @isTest
    static void testCreateRelatedQuotesByCategory() {
        // Retrieve test data
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Product2> productsList = [SELECT Id, ProductCode, Name, Is_Service__c, Stock__c from Product2];
        

        Test.startTest();
        List<OpportunityLineItem> olis = createOppLineItems(opp, productsList);
        Test.stopTest();

        /**Product2 service = [SELECT Id, Required_materials__c, category__c, family, is_service__c FROM Product2 where is_Service__c = true LIMIT 1];
        
        // Create request object
        TallercanUtils.Request request = new TallercanUtils.Request();
        request.receptionId = opp.Id;
        request.category = 'Standard';
        request.servicesObject = new List<Product2>{service};
        request.addServices = true;
        
        List<TallercanUtils.Request> requests = new List<TallercanUtils.Request> { request };

        // Test the createRelatedQuotesByCategory method
        Test.startTest();
        TallercanUtils.createRelatedQuotesByCategory(requests);
        Test.stopTest();**/
        
        // Verify OpportunityLineItems creation
        List<OpportunityLineItem> oppLineItems = [SELECT Id, OpportunityId, Product2Id, Quantity, UnitPrice FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        System.assertEquals(2, oppLineItems.size(), 'There should be 2 OpportunityLineItems');  
    }
}