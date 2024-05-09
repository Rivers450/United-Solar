trigger email_related_contact on Contact (before insert, before update) {
    Set<Id> accountIds = new Set<Id>();
    Map<Id, Set<String>> accountContactEmailsMap = new Map<Id, Set<String>>();

    for(Contact con : Trigger.new) {
        if(con.AccountId != null) {
            accountIds.add(con.AccountId);
            if(!accountContactEmailsMap.containsKey(con.AccountId)) {
                accountContactEmailsMap.put(con.AccountId, new Set<String>());
            }
            accountContactEmailsMap.get(con.AccountId).add(con.Email);
        }
    }
    Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT Id, (SELECT Email FROM Contacts WHERE Id != :Trigger.new AND Email != null) FROM Account WHERE Id IN :accountIds]);

    for(Contact con : Trigger.new) {
        if(con.AccountId != null && accountsMap.containsKey(con.AccountId)) {
            for(Contact relatedContact : accountsMap.get(con.AccountId).Contacts) {
                if(!relatedContact.Email.endsWithIgnoreCase(con.Email.substringAfter('@'))) {
                    con.addError('The email address is not in the same after the @ sign relating to the account.');
                }
            }
        }
    }
}
