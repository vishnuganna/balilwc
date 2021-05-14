@SuppressWarnings('PMD.ExcessiveParameterList,PMD.CognitiveComplexity')
public with sharing class SendEmailForKFAlert {
    public static Messaging.SingleEmailMessage sendEmaill(
        Id toRecipients,
        String template,
        String emailSubject,
        List<EmailTemplate> emailTemplateData,
        List<OrgWideEmailAddress> orgWideEmailAddList
    ) {
        // List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if (orgWideEmailAddList != null && !orgWideEmailAddList.isEmpty()) {
            email.setSubject(emailSubject);
            // email.setToAddresses(toRecipients);
            email.setTargetObjectId(toRecipients);
            email.setHtmlBody(template);
            email.setorgWideEmailAddressId(orgWideEmailAddList[0].Id);
            email.setTemplateId(emailTemplateData.get(0).Id);
            email.setSaveAsActivity(false);
            // allMails.add(email);
        }
        // return allMails;
        return email;
    }

    public static void sendOutEmails(List<Messaging.SingleEmailMessage> allMails) {
        if (allMails != null && !allMails.isEmpty()) {
            try {
                // Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
                Messaging.sendEmail(allMails);
            } catch (EmailException e) {
                System.debug(LoggingLevel.INFO, '[U-02] sendTemplatedEmail error' + e);
            }
        }
    }

    private class EmailAlertException extends Exception {
    }
}