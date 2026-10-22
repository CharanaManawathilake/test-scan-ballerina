import ballerina/io;

public function main() {
    // Issue: checkpanic instead of check.
    int value = checkpanic int:fromString("7");
    io:println(value);
}
