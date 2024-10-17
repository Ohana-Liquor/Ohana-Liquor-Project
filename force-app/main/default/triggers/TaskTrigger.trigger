trigger TaskTrigger on Task (before insert, before update) {

    List<Lead> leads = new List<Lead>();

    for(Task task : Trigger.new) {
            if (task.WhoId != null && task.WhoId.getSObjectType() == Lead.SObjectType) {
                Lead lead = [SELECT Id, Activity_Date__c FROM Lead WHERE Id =:task.WhoId];
                lead.Activity_Date__c = System.now();
                leads.add(lead);
                
            }
    }

    update leads;
}