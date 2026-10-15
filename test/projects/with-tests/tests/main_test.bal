import ballerina/test;

@test:Config {}
function testFromString() {
    // Issue: checkpanic instead of check, in a test source.
    int value = checkpanic int:fromString("7");
    test:assertEquals(value, 7);
}
