trigger OpportunityTrigger on Opportunity (before insert, before update) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            OpportunityTriggerHandler.OpportunityTriggerInsert(Trigger.new, Trigger.oldMap);
            OpportunityTriggerQuotaValidation.QuotaValidation(Trigger.new);
        }

        if(Trigger.isUpdate){
            OpportunityTriggerHandler.OpportunityTriggerUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}