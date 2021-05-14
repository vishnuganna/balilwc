public with sharing class RulesEngine {
    public static void execute(set<String> parentObjectIds, RulesEngineConfig.Scope scope) {
        RulesEvaluator evaluator = RulesEngineConfig.Evaluator.get(scope);
        evaluator.evaluate(parentObjectIds);
    }
}