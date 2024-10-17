trigger LeadSurveyTrigger on LeadSurvey__c (before insert, before update) {
    List<Lead> leads = new List<Lead>();

    // lead와 연관된 leadSurvey 생성 시 lead의 Activity_Date__c 필드를 현재 시간으로 업데이트
    for(LeadSurvey__c leadSurvey : Trigger.new) {
        if (leadSurvey.leadId__c != null) {
            Lead lead = [SELECT Id, Activity_Date__c FROM Lead WHERE Id =:leadSurvey.leadId__c];
            lead.Activity_Date__c = System.now();
            leads.add(lead);    
        }
    }

    update leads;
}