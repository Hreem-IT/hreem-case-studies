package io.hreem.studies;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import javax.inject.Named;
import java.util.Map;

@Named("handler")
public class Handler implements RequestHandler<Map<String, String>, String> {
    private static Gson gson = new GsonBuilder().create();

    @Override
    public String handleRequest(Map<String, String> event, Context context) {
        LambdaLogger logger = context.getLogger();

        // log execution details
        String eventJson = gson.toJson(event);
        logger.log("CONTEXT: " + gson.toJson(context));
        logger.log("ENVIRONMENT VARIABLES: " + gson.toJson(System.getenv()));
        logger.log("EVENT: " + eventJson);
        
        return "Hello from Quarkus";
    }

}
