#ifndef CPPLIB_E26AAADE_5F53_496F_9031_DF57C47DD995
#define CPPLIB_E26AAADE_5F53_496F_9031_DF57C47DD995

#include <string>
#include <vector>
#include <memory>

// Include the CMake-generated export header
#include "cpplib/export.h"

namespace cpplib
{

    /**
     * @brief A utility class for string formatting and logging using fmt library
     */
    class CPPLIB_EXPORT StringFormatter
    {
    public:
        StringFormatter();
        ~StringFormatter();

        /**
         * @brief Format a string with arguments using fmt library
         * @param format Format string
         * @param args Format arguments
         * @return Formatted string
         */
        template <typename... Args>
        std::string format(const std::string &format, Args &&...args);

        /**
         * @brief Log a formatted message with timestamp
         * @param level Log level (INFO, WARN, ERROR)
         * @param format Format string
         * @param args Format arguments
         */
        template <typename... Args>
        void log(const std::string &level, const std::string &format, Args &&...args);

        /**
         * @brief Get version information
         * @return Version string
         */
        static std::string getVersion();

        /**
         * @brief Check if library was built as static or dynamic
         * @return Library type string
         */
        static std::string getLibraryType();

    private:
        class Impl;
        std::unique_ptr<Impl> pImpl;
    };

    /**
     * @brief A simple math utility class
     */
    class CPPLIB_EXPORT MathUtils
    {
    public:
        /**
         * @brief Calculate factorial of a number
         * @param n Input number
         * @return Factorial result
         */
        static long long factorial(int n);

        /**
         * @brief Check if a number is prime
         * @param n Input number
         * @return True if prime, false otherwise
         */
        static bool isPrime(int n);

        /**
         * @brief Generate Fibonacci sequence up to n terms
         * @param n Number of terms
         * @return Vector containing Fibonacci sequence
         */
        static std::vector<long long> fibonacci(int n);
    };

} // namespace cpplib

// Include template implementations
#include "cpplib/cpplib_impl.h"

#endif /* CPPLIB_E26AAADE_5F53_496F_9031_DF57C47DD995 */
