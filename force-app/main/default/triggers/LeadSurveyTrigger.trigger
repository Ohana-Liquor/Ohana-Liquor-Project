trigger LeadSurveyTrigger on LeadSurvey__c (before insert, before update) {
    List<Lead> leads = new List<Lead>();

    for(LeadSurvey__c leadSurvey : Trigger.new) {
        if (leadSurvey.leadId__c != null) {
            Lead lead = [SELECT Id, Activity_Date__c FROM Lead WHERE Id =:leadSurvey.leadId__c];
            lead.Activity_Date__c = System.now();
            leads.add(lead);    
        }
    }

    update leads;
}