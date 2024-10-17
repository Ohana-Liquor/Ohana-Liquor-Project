trigger TaskTrigger on Task (before insert, before update) {

    List<Lead> leads = new List<Lead>();
    
    // lead와 연관된 task 생성 시 lead의 Activity_Date__c 필드를 현재 시간으로 업데이트
    for(Task task : Trigger.new) {
            if (task.WhoId != null && task.WhoId.getSObjectType() == Lead.SObjectType) {
                Lead lead = [SELECT Id, Activity_Date__c FROM Lead WHERE Id =:task.WhoId];
                lead.Activity_Date__c = System.now();
                leads.add(lead);
                
            }
    }

    update leads;
}