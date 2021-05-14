public interface RuleEvaluator {
    void evaluate(List<Sobject> records);
    void deleteBestActions(List<Sobject> records);
}