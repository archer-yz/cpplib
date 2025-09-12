#include <cpplib/cpplib.h>
#include <iostream>
#include <vector>

int main()
{
    std::cout << "=== CPPLib Demo Application ===\n\n";

    // Display library information
    std::cout << "Library Version: " << cpplib::StringFormatter::getVersion() << "\n";
    std::cout << "Library Type: " << cpplib::StringFormatter::getLibraryType() << "\n\n";

    // Test StringFormatter
    std::cout << "=== String Formatter Demo ===\n";
    cpplib::StringFormatter formatter;

    // Test basic formatting
    std::string formatted = formatter.format("Hello, {}! The answer is {}.", "World", 42);
    std::cout << "Formatted string: " << formatted << "\n";

    // Test logging functionality
    std::cout << "\n=== Logging Demo ===\n";
    formatter.log("INFO", "Application started successfully");
    formatter.log("WARN", "This is a warning message with value: {}", 123);
    formatter.log("ERROR", "Error processing item {} with status {}", "example.txt", "failed");

    // Test MathUtils
    std::cout << "\n=== Math Utils Demo ===\n";

    // Test factorial
    int fact_input = 10;
    long long factorial_result = cpplib::MathUtils::factorial(fact_input);
    std::cout << "Factorial of " << fact_input << " = " << factorial_result << "\n";

    // Test prime checking
    std::vector<int> test_numbers = {2, 17, 25, 29, 100, 101};
    std::cout << "\nPrime number tests:\n";
    for (int num : test_numbers)
    {
        bool is_prime = cpplib::MathUtils::isPrime(num);
        std::cout << num << " is " << (is_prime ? "prime" : "not prime") << "\n";
    }

    // Test Fibonacci sequence
    int fib_count = 15;
    auto fibonacci_seq = cpplib::MathUtils::fibonacci(fib_count);
    std::cout << "\nFirst " << fib_count << " Fibonacci numbers:\n";
    for (size_t i = 0; i < fibonacci_seq.size(); ++i)
    {
        std::cout << fibonacci_seq[i];
        if (i < fibonacci_seq.size() - 1)
            std::cout << ", ";
    }
    std::cout << "\n";

    // Test formatted logging with math results
    std::cout << "\n=== Combined Demo ===\n";
    formatter.log("INFO", "Calculated factorial({}) = {}", fact_input, factorial_result);
    formatter.log("INFO", "Generated {} Fibonacci numbers", fib_count);

    // Demonstrate error handling
    std::cout << "\n=== Error Handling Demo ===\n";
    try
    {
        // Test with valid format but potentially tricky edge case
        std::string test_format = formatter.format("Test message: {}", "success");
        std::cout << "Result: " << test_format << "\n";
    }
    catch (const std::exception &e)
    {
        std::cout << "Caught exception: " << e.what() << "\n";
    }

    std::cout << "\n=== Demo Complete ===\n";
    return 0;
}
