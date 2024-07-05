@IsTest
public class ServiceMonitoringTest {
    
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
        
        Map<Id, PricebookEntry> mapProductPricebook = getPBMap();
        
        
        for(Product2 p : products){
            //Create OppLineItems
            oli1 = new OpportunityLineItem();
            oli1.PricebookEntryId = mapProductPricebook.get(p.Id).Id;
            oli1.Quantity = 1;
            oli1.opportunityId = reception.Id;
            oli1.product2id = p.Id;
            oli1.UnitPrice = mapProductPricebook.get(p.Id).UnitPrice * oli1.Quantity;
            oliToInsert.add(oli1);
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
    
    
    @isTest
    static void serviceMonitoringCreationStockOK(){
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        // Create Account
        Account acc2 = new Account();
        acc2.LastName = 'Prueba2';
        acc2.FirstName = 'Account 2';
        acc2.BillingStreet = 'Calle Inventada 2';
        acc2.BillingCity = 'Santander';
        acc2.BillingCountry = 'Spain';
        acc2.Phone = '633445533';
        acc2.PersonHomePhone = '942333333';
        acc2.PersonEmail = 'prueba@prueba.com';
        acc2.Document_Number__c = '76655443H';
        acc2.RecordTypeId = personAccountRecordTypeId;
        insert acc2;

        // Create Vehicle
        Vehicle__c v2 = new Vehicle__c();
        v2.Name = 'Test2';
        v2.Chasis_number__c = '465859845';
        v2.DT_Car_Registration_Date__c = Date.today();
        v2.DT_Next_ITV_Revision_Date__c = Date.today().addDays(40);
        v2.PK_Fuel_Type__c = 'Fuel Oil';
        v2.PK_Vehicle_Brand__c = 'BMW';
        v2.PK_Vehicle_Model__c = '2 Series';
        v2.TX_Car_Number_Plate__c = '4321HTT';
        v2.LK_Vehicle_Owner__c = acc2.Id;
        insert v2;
        
        Product2 serviceCreated = createService('matCategory');
        Product2 materialWithStock = createMaterial(true);
        //Create services and materials
        List<Product2> materialAndServiceList = new List<Product2>();
        materialAndServiceList.add(materialWithStock);
        materialAndServiceList.add(serviceCreated);
        insert materialAndServiceList;
        
		//Asign service and material with id to variables
        List<Product2> productsList = [SELECT Id, ProductCode, Name, Is_Service__c, Stock__c from Product2];
        for(Product2 p2:productsList){
            if(p2.Is_Service__c){
                serviceCreated = p2;
            }else{
                materialWithStock = p2;
            }
        }
        

        
        // Create reception
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Opp Prueba 2';
        opp2.Description = 'Prueba de oportunidad';
        opp2.AccountId = acc2.id;
        opp2.Amount = 500;
        opp2.StageName = 'Created';
        opp2.LK_Vehicle__c = v2.Id;
        insert opp2;
        
        Opportunity opp2record = [SELECT Id from Opportunity LIMIT 1];
        
        List<OpportunityLineItem> olis = createOppLineItems(opp2record, productsList);
        
        //Create Quote
        Quote quo2 = new Quote();
        quo2.Name = 'Presupuesto Prueba 2';
        quo2.Status = 'Accepted';
        quo2.OpportunityId = opp2record.Id;
        insert quo2;
        
        //Create Quote Line Items
        List<QuoteLineItem> qliList = createQuoteLineItems(productsList, quo2, getPBMap());


        Test.startTest();
        
        //Create Service Monitoring with stock
        Service_monitoring__c sm1 = new Service_monitoring__c();
        sm1.Related_reception_service__c = opp2record.Id;
        sm1.related_service__c = serviceCreated.Id;
        
        insert sm1;
        
        //Create Service Monitoring with stock
        Service_monitoring__c smInserted = [SELECT Id, Status__c FROM Service_monitoring__c LIMIT 1];
        System.AssertEquals('In queue', smInserted.Status__c);
         
        Test.stopTest();
    }
    
    @isTest
    static void serviceMonitoringCreationStockKO(){
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        // Create Account
        Account acc2 = new Account();
        acc2.LastName = 'Prueba2';
        acc2.FirstName = 'Account 2';
        acc2.BillingStreet = 'Calle Inventada 2';
        acc2.BillingCity = 'Santander';
        acc2.BillingCountry = 'Spain';
        acc2.Phone = '633445533';
        acc2.PersonHomePhone = '942333333';
        acc2.PersonEmail = 'prueba@prueba.com';
        acc2.Document_Number__c = '76655443H';
        acc2.RecordTypeId = personAccountRecordTypeId;
        insert acc2;

        // Create Vehicle
        Vehicle__c v2 = new Vehicle__c();
        v2.Name = 'Test2';
        v2.Chasis_number__c = '465859845';
        v2.DT_Car_Registration_Date__c = Date.today();
        v2.DT_Next_ITV_Revision_Date__c = Date.today().addDays(40);
        v2.PK_Fuel_Type__c = 'Fuel Oil';
        v2.PK_Vehicle_Brand__c = 'BMW';
        v2.PK_Vehicle_Model__c = '2 Series';
        v2.TX_Car_Number_Plate__c = '4321HTT';
        v2.LK_Vehicle_Owner__c = acc2.Id;
        insert v2;
        
        Product2 serviceCreated = createService('matCategory');
        Product2 materialWithStock = createMaterial(false);
        //Create services and materials
        List<Product2> materialAndServiceList = new List<Product2>();
        materialAndServiceList.add(materialWithStock);
        materialAndServiceList.add(serviceCreated);
        insert materialAndServiceList;
        
		//Asign service and material with id to variables
        List<Product2> productsList = [SELECT Id, ProductCode, Name, Is_Service__c, Stock__c from Product2];
        for(Product2 p2:productsList){
            if(p2.Is_Service__c){
                serviceCreated = p2;
            }else{
                materialWithStock = p2;
            }
        }
        

        
        // Create reception
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Opp Prueba 2';
        opp2.Description = 'Prueba de oportunidad';
        opp2.AccountId = acc2.id;
        opp2.Amount = 500;
        opp2.StageName = 'Created';
        opp2.LK_Vehicle__c = v2.Id;
        insert opp2;
        
        Opportunity opp2record = [SELECT Id from Opportunity LIMIT 1];
        
        List<OpportunityLineItem> olis = createOppLineItems(opp2record, productsList);
        
        //Create Quote
        Quote quo2 = new Quote();
        quo2.Name = 'Presupuesto Prueba 2';
        quo2.Status = 'Accepted';
        quo2.OpportunityId = opp2record.Id;
        insert quo2;
        
        //Create Quote Line Items
        List<QuoteLineItem> qliList = createQuoteLineItems(productsList, quo2, getPBMap());


        Test.startTest();
        
        //Create Service Monitoring without stock
        Service_monitoring__c sm1 = new Service_monitoring__c();
        sm1.Related_reception_service__c = opp2record.Id;
        sm1.related_service__c = serviceCreated.Id;
        
        insert sm1;
        
        Service_monitoring__c smInserted = [SELECT Id, Status__c FROM Service_monitoring__c LIMIT 1];
        System.AssertEquals('Waiting materials', smInserted.Status__c);
         
        Test.stopTest();
    }
    
}