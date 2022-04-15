/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class InboundEmailService implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
       try {
            String subject = email.subject;
            String plainTextBody = email.plainTextBody;
            
            // Find the Contact based on the Case Creator's email address       
            Contact contact = null;
            try {
                contact = [Select Id, Name, Email, AccountId From Contact Where Email = :email.fromAddress Limit 1];
            } catch (QueryException qe) {
                System.debug('Contact with email address ' + email.fromAddress + ' not found, case will be created and moved to Case Exception queue');
            }
            
            // Could be an User
            User user = null;
            if ( contact == null ) {
                try {
                    user = [ SELECT Id, Email, Name FROM User where Email = :email.fromAddress Limit 1];
                } catch (QueryException qe) {
                    System.debug('Testing');
                    System.debug('User with email address ' + email.fromAddress + ' not found, case will be created and moved to Case Exception queue');
                }
            }
        Task task = new Task();
            task.WhatId = '12345'; //caseId;
            task.WhatId ='something';
            if ( contact != null ) {
                task.WhoId = contact.Id;
            }
            task.ActivityDate = Date.today();
            task.Subject = 'Inbound Email: ' + subject;
            task.Description = plainTextBody;
            task.Priority = 'Normal';
            task.Status = 'Completed';
            
            insert task;
          System.debug('Task inserted from inbound email Look in the logs');
        } catch (Exception ex) {
            System.debug('General exception! Looks in the logs' + ex);
        }
        return result;
    }
}
