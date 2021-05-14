trigger TaskTrigger on Task(after update, before delete, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            if (GreenSheet.taskUpdate == true) {
                GreenSheet.taskUpdate = false;
                GreenSheet.greensheetUpdate(Trigger.new);
                GreenSheetNavigate.doGreenSheetCountCalculation(Trigger.new, Trigger.old);
            }
        }

        if (Trigger.isDelete) {
            TaskClass.greenSheetDeleteAfter();
            GreenSheetNavigate.doGreenSheetCountCalculation(null, Trigger.old);
        }
    }

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            TaskClass.greenSheetDeleteBefore(Trigger.old);
        }
    }
}