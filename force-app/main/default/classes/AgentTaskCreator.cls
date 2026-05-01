public class AgentTaskCreator {

    @InvocableMethod(label='Create Tasks from JSON' category='Agentforce')
    public static void createTasks(List<Request> requests) {
        List<Task> tasksToInsert = new List<Task>();

        for (Request req : requests) {
            try {
                String jsonStr = req.rawAgentResponse;
                if (String.isBlank(jsonStr)) continue;

                // 1. Extract JSON block (removes any AI chatter outside the { })
                Integer startIdx = jsonStr.indexOf('{');
                Integer endIdx = jsonStr.lastIndexOf('}') + 1;
                if (startIdx == -1 || endIdx == -1) continue;
                String cleanJson = jsonStr.substring(startIdx, endIdx);

                // 2. Parse the JSON
                Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(cleanJson);
                
                // 3. Extract the Tasks List
                List<Object> tasksList = (List<Object>)data.get('Tasks');

                if (tasksList != null) {
                    for (Object obj : tasksList) {
                        Map<String, Object> taskMap = (Map<String, Object>)obj;
                        
                        Task t = new Task();
                        t.Subject = (String)taskMap.get('Subject');
                        t.Description = (String)taskMap.get('Description');
                        t.Status = 'Not Started';
                        t.Priority = 'Normal';
                        t.OwnerId = UserInfo.getUserId();
                        
                        // 4. Set the WhatId (Prioritize AccountId from JSON, fallback to recordId)
                        if (data.containsKey('AccountId') && data.get('AccountId') != null) {
                            t.WhatId = Id.valueOf((String)data.get('AccountId'));
                        } else if (String.isNotBlank(req.recordId)) {
                            t.WhatId = Id.valueOf(req.recordId);
                        }
                        
                        tasksToInsert.add(t);
                    }
                }
            } catch (Exception e) {
                System.debug('Task Parser Error: ' + e.getMessage());
            }
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }

    public class Request {
        @InvocableVariable(label='Raw Agent Response' required=true)
        public String rawAgentResponse;

        @InvocableVariable(label='Related Record ID (WhatId)')
        public String recordId;
    }
}