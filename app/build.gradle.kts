plugins {
    java
    application
    id("org.openjfx.javafxplugin") version "0.1.0"
    id("org.danilopianini.gradle-java-qa") version "1.155.0"
}

repositories {
    mavenCentral()
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

javafx {
    version = "21.0.2"
    modules = listOf("javafx.controls", "javafx.fxml", "javafx.graphics", "javafx.base")
}

dependencies {
    compileOnly("com.github.spotbugs:spotbugs-annotations:4.9.8")

    implementation("org.apache.commons:commons-csv:1.10.0")
    implementation("org.slf4j:slf4j-api:2.0.17")
    implementation("org.jooq:jool:0.9.15")

    implementation("com.fasterxml.jackson.core:jackson-databind:2.17.2")
    implementation("com.fasterxml.jackson.core:jackson-annotations:2.17.2")
    implementation("com.fasterxml.jackson.core:jackson-core:2.17.2")

    runtimeOnly("ch.qos.logback:logback-classic:1.5.21")

    testImplementation(libs.junit.jupiter)
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.0")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")

    implementation(libs.guava)
}

application {
    //mainClass.set("it.unibo.unibodget.unibodget")
    mainClass.set("it.unibo.unibodget.view.currency_converter.TestCurrencyConverterTestApp")
    //mainClass.set("it.unibo.unibodget.persistency.parser.impl.TestBudgetLimitParsing")
    //mainClass.set("it.unibo.unibodget.view.currency_converter.SimpleLabelOutputTest")
}

tasks.test {
    useJUnitPlatform()
}

tasks.withType<Javadoc>().configureEach {
    isFailOnError = false
}