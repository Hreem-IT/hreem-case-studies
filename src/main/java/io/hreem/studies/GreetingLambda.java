package io.hreem.studies;

import javax.inject.Inject;
import javax.inject.Named;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import lombok.val;

@Named("greet")
public class GreetingLambda implements RequestHandler<GreetingInput, Greeting> {

    @Inject
    NumberGenerator numberGenerator;

    @Override
    public Greeting handleRequest(GreetingInput input, Context context) {
        double magicNumber = numberGenerator.generateNumber();
        val greeting = new Greeting();

        val greetingBuilder = new StringBuilder("Hello ");
        val recipientName = input == null || input.getName() == null || input.getName().isEmpty() ? 
            "Stuart" : input.getName();
        greetingBuilder.append(recipientName);
        greeting.setGreetingMessage(greetingBuilder.append(", your magic number is: " ).append(magicNumber).toString());
        return greeting;
    }
}
