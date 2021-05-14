/**
 * Tests for External Links class
 */
@IsTest
private with sharing class ExternalLinksTest {
    @IsTest
    static void testGetKFLearnUrl() {
        String url = ExternalLinks.getKFLearnUrl();
        System.assertNotEquals(null, url);
        System.assert(url.length() > 0, 'KF Learn URL is empty');
    }
}