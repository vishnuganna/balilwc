public with sharing class Landing {
    @AuraEnabled
    public static List<Id> getSetOfReportees() {
        Id userId = UserInfo.getUserId();
        List<Id> idList = new List<Id>();
        if (userId != null) {
            String query = 'SELECT Id,Name,ManagerId from user where ManagerId =:userId';
            Map<String, Object> parmters = new Map<String, Object>();
            parmters.put('userId', userId);
            List<User> listOfReportees = DataFactory.read(query, parmters);
            idList.add(userId);
            for (User reportees : listOfReportees) {
                idList.add(reportees.Id);
            }
        }
        return idList;
    }
    @AuraEnabled
    public static String checkIfLoggedUserIsManager() {
        try {
            String isManager;
            String loggedinUser = UserInfo.getUserId();
            String query = 'SELECT Id,Name,ManagerId from user where ManagerId =:loggedinUser';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('loggedinUser', loggedinUser);
            List<User> listUser = DataFactory.read(query, paramters);
            if (!listUser.isEmpty()) {
                isManager = 'Manager';
            } else {
                isManager = 'Not Manager';
            }
            return isManager;
        } catch (Exception ex) {
            throw new LandingException('Error occured while getting Manager Info');
        }
    }
    @AuraEnabled
    public static Map<Id, String> getreportLinkMap(String reportName) {
        Map<Id, String> reportDetailsMap = new Map<Id, String>();
        Map<String, Object> params = new Map<String, Object>();
        String reportNames = '%' + reportName + '%';
        params.put('reportNames', reportNames);
        List<Report> reports = DataFactory.read(
            'SELECT Id,Name FROM Report WHERE DeveloperName LIKE :reportNames LIMIT 20',
            params
        );
        if (reports.size() > 0) {
            for (Report rep : reports) {
                reportDetailsMap.put(rep.Id, rep.Name);
            }
            return reportDetailsMap;
        }
        return null;
    }

    private class LandingException extends Exception {
    }
}