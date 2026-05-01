global class AgentTaskParser {

    @InvocableMethod(label='Parse Agent JSON with AccountID' category='Agentforce')
    public static List<ActionResult> parseJson(List<String> jsonInputs) {
        List<ActionResult> results = new List<ActionResult>();
        
        for (String jsonStr : jsonInputs) {
            try {
                if (String.isBlank(jsonStr)) {
                    results.add(new ActionResult());
                    continue;
                }

                // CLEANER: Ensures we only parse the part between { and }
                Integer startIdx = jsonStr.indexOf('{');
                Integer endIdx = jsonStr.lastIndexOf('}') + 1;
                String cleanJson = jsonStr.substring(startIdx, endIdx);

                // Deserialize into our global class
                ActionResult res = (ActionResult)JSON.deserialize(cleanJson, ActionResult.class);
                results.add(res);
            } catch (Exception e) {
                System.debug('Parsing Error: ' + e.getMessage());
                results.add(new ActionResult());
            }
        }
        return results;
    }

    global class ActionResult {
        @InvocableVariable(label='Account ID') 
        public String AccountId; // <--- Added this to capture the ID from your Prompt
        
        @InvocableVariable(label='Summary') 
        public String Summary;
        
        @InvocableVariable(label='Follow Up Date') 
        public String FollowUpDate;
        
        @InvocableVariable(label='Tasks') 
        public List<TaskData> Tasks;
    }

    global class TaskData {
        @InvocableVariable(label='Subject') 
        public String Subject;
        
        @InvocableVariable(label='Description') 
        public String Description;
    }
}