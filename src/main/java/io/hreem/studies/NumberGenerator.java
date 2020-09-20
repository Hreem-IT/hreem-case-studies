package io.hreem.studies;

import java.util.Random;

import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class NumberGenerator {

    final Random random = new Random();

    public double generateNumber() {
        double num = 0;
        double s = 1;
        int iterations = random.nextInt(10000000-9999900) + 9999900;
        for (int i = 1; i < iterations; i++) {
            num += s/i;
            num += random.nextInt(10000000-9999900) + 9999900;
            s = -s;
        }
        return num*4;
    }
}
