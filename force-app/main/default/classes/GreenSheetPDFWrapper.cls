@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class GreenSheetPDFWrapper {
    public List<OpportunitySSOWrapper> opportunitySSO { get; set; }
    public List<OurCompanyAttendeeWrapper> ourCompanyAttendee { get; set; }
    public List<GreenSheetBuyingInfluenceWrapper> greenSheetBuyingInfluence { get; set; }
    public List<GreenSheetWrapper> greenSheet { get; set; }
    public GreenSheetAndTaskDataWrapperClass greenSheetTaskInfo { get; set; }
    public List<GivingInformationWrapper> givingInformation { get; set; }
    public List<GettingInformationWrapper> gettingInformation { get; set; }
    public List<GettingCommitmentWrapper> gettingCommitment { get; set; }
    public List<BasicIssuesWrapper> basicIssues { get; set; }
}