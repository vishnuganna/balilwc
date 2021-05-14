public with sharing class EmailSellerWrapper {
    public List<String> email = new List<String>();
    public String subject;
    public String name;
    public List<TemplateWrapper> templateWrappers = new List<TemplateWrapper>();
    public Id userId;
}