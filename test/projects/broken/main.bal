import ballerina/io;

public function main() {
    // Does not compile: a string is assigned to an int.
    int quantity = "3";
    io:println(quantity);
}
