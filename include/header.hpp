/**
 * @file   header.hpp
 * @brief  C/C++ header files.
 * @author zer0
 * @date   2016-01-25
 * @remarks
 *  GCC Command:
 *  @code
 *   g++ -std=c++11 -MD -MF header.d header.hpp
 *  @endcode
 */

// C Libraries.
#include <assert.h>
#include <ctype.h>
#include <errno.h>
#include <fenv.h>
#include <float.h>
#include <inttypes.h>
#include <iso646.h>
#include <limits.h>
#include <locale.h>
#include <math.h>
#include <setjmp.h>
#include <signal.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tgmath.h>
#include <time.h>
#include <wchar.h>
#include <wctype.h>

#if defined(__clang__)
//#include <uchar.h>
#elif defined(__GNUC__)
#include <uchar.h>
#else
#pragma message("Unknown compiler.")
#endif

#include <cassert>
#include <cctype>
#include <cerrno>
#include <cfenv>
#include <cfloat>
#include <cinttypes>
#include <ciso646>
#include <climits>
#include <clocale>
#include <cmath>
#include <csetjmp>
#include <csignal>
#include <cstdarg>
#include <cstdbool>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctgmath>
#include <ctime>
#include <cwchar>
#include <cwctype>


#if defined(__clang__)
//#include <cuchar>
#elif defined(__GNUC__)
//#include <cuchar>
#else
#pragma message("Unknown compiler.")
#endif

// Containers
#include <array>
#include <bitset>
#include <deque>
#include <forward_list>
#include <list>
#include <map>
#include <queue>
#include <set>
#include <stack>
#include <unordered_map>
#include <unordered_set>
#include <vector>

// Input/Output.
#include <fstream>
#include <iomanip>
#include <ios>
#include <iosfwd>
#include <iostream>
#include <istream>
#include <ostream>
#include <sstream>
#include <streambuf>

// Multi-threading.
#include <atomic>
#include <condition_variable>
#include <future>
#include <mutex>
#include <thread>

// Miscellaneous headers
#include <algorithm>
#include <chrono>
#include <complex>
#include <exception>
#include <functional>
#include <initializer_list>
#include <iterator>
#include <limits>
#include <locale>
#include <memory>
#include <new>
#include <numeric>
#include <random>
#include <ratio>
#include <regex>
#include <stdexcept>
#include <string>
#include <system_error>
#include <tuple>
#include <typeindex>
#include <typeinfo>
#include <type_traits>
#include <utility>
#include <valarray>

#if defined(__clang__)
#include <codecvt>
#elif defined(__GNUC__)
//#include <codecvt>
#else
#pragma message("Unknown compiler.")
#endif

