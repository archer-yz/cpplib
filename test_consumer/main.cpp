#include <cpplib/cpplib.h>
#include <iostream>

int main()
{
    std::cout << "=== Testing Installed CPPLib ===\n";

    // Test that the library works
    cpplib::StringFormatter formatter;
    std::cout << "Library Version: " << cpplib::StringFormatter::getVersion() << "\n";
    std::cout << "Library Type: " << cpplib::StringFormatter::getLibraryType() << "\n";

    // Test basic functionality
    std::string result = formatter.format("Testing installed library: {}", "SUCCESS");
    std::cout << result << "\n";

    // Test math utilities
    long long fact = cpplib::MathUtils::factorial(5);
    std::cout << "5! = " << fact << "\n";

    std::cout << "=== Install Test Complete ===\n";
    return 0;
}
