#include "cpplib/cpplib.h"
#include <fmt/format.h>
#include <fmt/chrono.h>
#include <chrono>
#include <iostream>
#include <algorithm>

namespace cpplib
{

    // Private implementation class
    class StringFormatter::Impl
    {
    public:
        Impl() = default;
        ~Impl() = default;
    };

    StringFormatter::StringFormatter() : pImpl(std::make_unique<Impl>()) {}

    StringFormatter::~StringFormatter() = default;

    std::string StringFormatter::getVersion()
    {
        return "1.0.0";
    }

    std::string StringFormatter::getLibraryType()
    {
#ifdef CPPLIB_STATIC
        return "Static Library";
#else
        return "Dynamic Library";
#endif
    }

    // MathUtils implementation
    long long MathUtils::factorial(int n)
    {
        if (n < 0)
            return -1;
        if (n <= 1)
            return 1;

        long long result = 1;
        for (int i = 2; i <= n; ++i)
        {
            result *= i;
        }
        return result;
    }

    bool MathUtils::isPrime(int n)
    {
        if (n <= 1)
            return false;
        if (n <= 3)
            return true;
        if (n % 2 == 0 || n % 3 == 0)
            return false;

        for (int i = 5; i * i <= n; i += 6)
        {
            if (n % i == 0 || n % (i + 2) == 0)
            {
                return false;
            }
        }
        return true;
    }

    std::vector<long long> MathUtils::fibonacci(int n)
    {
        std::vector<long long> result;
        if (n <= 0)
            return result;

        result.push_back(0);
        if (n == 1)
            return result;

        result.push_back(1);
        for (int i = 2; i < n; ++i)
        {
            result.push_back(result[i - 1] + result[i - 2]);
        }

        return result;
    }

} // namespace cpplib
