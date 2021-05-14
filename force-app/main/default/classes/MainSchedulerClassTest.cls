@isTest
public with sharing class MainSchedulerClassTest {
    /*@isTest
    public static void MainSchedulerClass_Test() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.StartTest();
            MainSchedulerClass mainObj = new MainSchedulerClass();
            String sch = getCronExpression(1);
            String id = System.schedule('Schedule Main Job', sch, mainObj);
            System.assertEquals(id != null, true, 'Job Triggered');
            Test.stopTest();
        }
    }

    public static String getCronExpression(Integer minsAddition) {
        //15:39 PM, 16 Oct, 2020
        //System.schedule('Schedule Job Name 1',  '0 39 15 16 OCT ? 2020', new CustomProfileScheduler());
        DateTime dtNow = Datetime.now();
        Integer minute = dtNow.minute() + minsAddition;
        Integer hr = dtNow.hour();
        Integer dd = dtNow.day();
        Integer month = dtNow.month();
        Integer yy = dtNow.year();
        String onespace = ' ';
        String mainExpression =
            '0' +
            onespace +
            minute +
            onespace +
            hr +
            onespace +
            dd +
            onespace +
            month +
            onespace +
            '?' +
            onespace +
            yy;
        return mainExpression;
    }*/
}