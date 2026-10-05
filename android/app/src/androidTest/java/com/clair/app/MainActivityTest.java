// android/app/src/androidTest/java/com/clair/app/MainActivityTest.java
//
// Patrol native-side test runner entrypoint.
//
// This file is REQUIRED by Patrol. It bridges Android's JUnit test runner
// (Parametrized) with Patrol's Dart-side test discovery. Without this file,
// the native instrumentation has zero test methods to enumerate and the
// summary shows "Total: 0".
//
// Docs: https://patrol.leancode.co/getting-started#android
//
// This file lives at:
//   android/app/src/androidTest/java/com/clair/app/MainActivityTest.java
// The package path MUST match the application's applicationId declared in
// android/app/build.gradle.kts (currently `com.clair.app`).

package com.clair.app;

// NOTE: In this project, MainActivity is a Kotlin class located at
// android/app/src/main/kotlin/com/mobile/mobile/MainActivity.kt.
// The package mismatch with applicationId (`com.clair.app`) is intentional:
// Flutter separates `namespace` (used by Kotlin sources) from `applicationId`
// (used at install time). We import it explicitly below.
import com.mobile.mobile.MainActivity;

import androidx.test.platform.app.InstrumentationRegistry;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import pl.leancode.patrol.PatrolJUnitRunner;

@RunWith(Parameterized.class)
public class MainActivityTest {
    @Parameters(name = "{0}")
    public static Object[] testCases() {
        PatrolJUnitRunner instrumentation =
            (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        // AndroidManifest.xml declares `.MainActivity`, so we keep MainActivity.class.
        // If you switch to FlutterActivity (no MainActivity subclass), change this
        // to io.flutter.embedding.android.FlutterActivity.class.
        instrumentation.setUp(MainActivity.class);
        instrumentation.waitForPatrolAppService();
        return instrumentation.listDartTests();
    }

    public MainActivityTest(String dartTestName) {
        this.dartTestName = dartTestName;
    }

    private final String dartTestName;

    @Test
    public void runDartTest() {
        PatrolJUnitRunner instrumentation =
            (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.runDartTest(dartTestName);
    }
}