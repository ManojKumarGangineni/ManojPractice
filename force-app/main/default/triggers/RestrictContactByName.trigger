trigger RestrictContactByName on Contact (before insert, before update,after insert,after update,after undelete) {
    For (Contact c : Trigger.New) {
        if(c.LastName == 'INVALIDNAME') {	//invalidname is invalid
            c.AddError('The Last Name "'+c.LastName+'" is not allowed for DML');
        }
        
    }
    
    if(trigger.isafter && trigger.IsInsert)
    {
        contactCheckBox.countActiveContacts(trigger.new);
    }
    
}