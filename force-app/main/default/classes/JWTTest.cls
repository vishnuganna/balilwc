/**
 * Tests for JWT class
 */
@IsTest
private with sharing class JWTTest {
    @IsTest
    static void testIssue() {
        JWT jwt = new JWT.JWTBuilder()
            .setAlgorithm('HS256')
            .setProperty('firstName', 'first')
            .setProperty('lastName', 'last')
            .setProperty('email', 'test@test.com')
            .setProperty('studentLicenseIds', 'test-license-id')
            .setProperty('clientId', 'test-client-id')
            .setPrivateKey('test-key')
            .build();
        String token = jwt.issue();
        System.assertNotEquals(null, token);
        System.assert(token.length() > 0, 'Token has no length');
    }
}