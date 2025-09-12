
// Template implementations for cpplib

#ifndef CPPLIB_IMPL_D7D5E5BE_115F_454F_86CD_B086FA902B84
#define CPPLIB_IMPL_D7D5E5BE_115F_454F_86CD_B086FA902B84
// This file contains the implementation of template functions that must be
// available to clients at compile time.

#include <fmt/format.h>
#include <fmt/chrono.h>
#include <chrono>
#include <iostream>

namespace cpplib
{

    template <typename... Args>
    std::string StringFormatter::format(const std::string &format, Args &&...args)
    {
        try
        {
            return fmt::format(fmt::runtime(format), std::forward<Args>(args)...);
        }
        catch (const std::exception &e)
        {
            return "Format error: " + std::string(e.what());
        }
    }

    template <typename... Args>
    void StringFormatter::log(const std::string &level, const std::string &format, Args &&...args)
    {
        auto now = std::chrono::system_clock::now();
        auto formatted_msg = this->format(format, std::forward<Args>(args)...);

        std::string log_line = fmt::format("[{:%Y-%m-%d %H:%M:%S}] [{}] {}",
                                           now, level, formatted_msg);
        std::cout << log_line << std::endl;
    }

} // namespace cpplib

#endif /* CPPLIB_IMPL_D7D5E5BE_115F_454F_86CD_B086FA902B84 */
