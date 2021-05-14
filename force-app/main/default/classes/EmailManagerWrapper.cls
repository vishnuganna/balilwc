public with sharing class EmailManagerWrapper {
    public List<String> email = new List<String>();
    public String subject;
    public List<EmailSellerWrapper> sellerWrappers = new List<EmailSellerWrapper>();
    public Id userId;
}