public with sharing class Util {
    private static final String NAMESPACE = Util.class.getName().substringBefore('Util').removeEnd('.');

    public static String getNamespace() {
        return NAMESPACE;
    }

    public static Boolean isNamespaced() {
        return String.isNotEmpty(NAMESPACE);
    }

    @AuraEnabled
    public static String getNamespaceWithUnderScores() {
        String nameSpace = getNamespace();

        if (nameSpace != '') {
            return nameSpace + '__';
        } else {
            return '';
        }
    }

    public static String applyNameSpace(String item) {
        String newValue = item;
        String nameSpace = getNamespaceWithUnderScores();
        if (String.isNotBlank(newValue)) {
            if (!item.containsIgnoreCase(nameSpace)) {
                newValue = nameSpace + item;
            }
        }
        return newValue;
    }
}