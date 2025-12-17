package com.ragul;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class AppTest {

    @Test
    void testMainMessage() {
        App app = new App();
        assertEquals(
            "Hi, welcome to the Ragul's CI/CD pipeline project!",
            app.getMessage()
        );
    }
}
