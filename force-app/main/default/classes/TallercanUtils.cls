/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-04-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class TallercanUtils {
    

     public class Request {
        

        @InvocableVariable(required=true)
        public List<Product2> servicesObject;

        @InvocableVariable(required=true)
        public String receptionId;
        
        @InvocableVariable(required=true)
        public String category;

        @InvocableVariable(required=true)
        public boolean addServices;
    }

    

    @InvocableMethod(label='create related opplineitems')
    public static void createRelatedQuotesByCategory(List<Request> requests){

        
        List<OpportunityLineItem> oppslineitems = new List<OpportunityLineItem>();
        
        for(Request req: requests){

            //Build materialservices list
            String materialservices = '';
            integer i = 1;
            for(Product2 p: req.servicesObject){
                materialservices+=p.Required_materials__c;
                if((i) < req.servicesObject.size()){
                    materialservices+=';';
                }
                i++;
            }

            System.debug('Lista de materiales:' + materialservices);

        
            List<String> materialServicesList = new List<String>(materialServices.split(';'));

            //Get reception and its
            List<Opportunity> receptioncreated = [SELECT id FROM Opportunity WHERE id =: req.receptionId];
            List<Product2> serviceandrelatedmaterials = null;
            if(!req.addServices){
                //Get materials
                serviceandrelatedmaterials = [SELECT id, productcode, name, family, category__c, Is_service__c 
                FROM Product2 
                WHERE Family in :materialServicesList AND category__c =: req.category AND IsActive = true];
            }else{
                serviceandrelatedmaterials = new List<Product2>();
                serviceandrelatedmaterials.addAll(req.servicesObject);
            }
            
            
            // get Set of Ids of the Object
            Set<Id> ids = new Set<Id>(new Map<Id, Product2>(serviceandrelatedmaterials).keySet());
            System.debug('Product2 Ids as Set<Id>: ' + ids);

            //Get pricebook entries for each material/service
            Pricebook2 pbStandard1 = [SELECT Id from Pricebook2 where IsStandard = true LIMIT 1];
            String pricebookidvar = pbStandard1.Id;//'01s68000002vx5zAAA';
            List<PricebookEntry> pricebookentries = [SELECT Id, UnitPrice, Product2Id
            FROM PricebookEntry
            WHERE Product2Id in :ids and isactive = true and Pricebook2Id =: pricebookidvar];
            //CREATE MAP of product-pricebookentry
            Map<Id,PricebookEntry> pricebookmap = new Map<Id,PricebookEntry>();
            for(PricebookEntry pb : pricebookentries){
                pricebookmap.put(pb.Product2Id, pb);
            }

            
            //Create 1 opp line item for each service/material
            OpportunityLineItem op;
            for(Product2 pp: serviceandrelatedmaterials){
                op = new OpportunityLineItem();
                op.PricebookEntryId = pricebookmap.get(pp.Id).Id;
                op.Quantity = 1;
                op.opportunityId = req.receptionId;
                op.product2id = pp.Id;
                oppslineitems.add(op);
                op.UnitPrice = pricebookmap.get(pp.Id).UnitPrice * op.Quantity;
            }
        }
        //insert opportunitylineitems
        insert oppslineitems;

    }

    
}