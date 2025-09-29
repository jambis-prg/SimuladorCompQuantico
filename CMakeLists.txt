cmake_minimum_required(VERSION 3.16)
project(qsim LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Corrige warning do pybind11/CMake
cmake_policy(SET CMP0148 NEW)
set(PYBIND11_FINDPYTHON ON)

# RPath relativo para libs do Conda
set(CMAKE_SKIP_RPATH TRUE)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)
set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib")
set(CMAKE_BUILD_RPATH "$CONDA_PREFIX/lib")
set(CMAKE_SKIP_RPATH FALSE)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Otimizações básicas para Release
if(CMAKE_BUILD_TYPE STREQUAL "Release")
  add_compile_options(-O3 -march=native -funroll-loops)
  # add_link_options(-flto) # opcional, ou usar CMAKE_CXX_FLAGS
endif()

# Find packages
find_package(pybind11 QUIET)
find_package(Eigen3 REQUIRED)
find_package(Armadillo QUIET)
find_package(OpenMP QUIET)

# 1️⃣ Biblioteca core
add_library(qsim_core STATIC
    src/simulator.cpp
)

# Includes e macros
target_include_directories(qsim_core PUBLIC
    ${CMAKE_SOURCE_DIR}/include
    ${EIGEN3_INCLUDE_DIRS}
)

target_compile_definitions(qsim_core PRIVATE EIGEN_NO_DEBUG)

# Link com Armadillo se encontrado
if(Armadillo_FOUND)
    target_include_directories(qsim_core PUBLIC ${ARMADILLO_INCLUDE_DIRS})
    target_link_libraries(qsim_core PRIVATE ${ARMADILLO_LIBRARIES})
endif()

# Link OpenMP se encontrado
if(OpenMP_CXX_FOUND)
    target_link_libraries(qsim_core PRIVATE OpenMP::OpenMP_CXX)
endif()

# 2️⃣ Executável principal
add_executable(qsim_bin src/main.cpp)
target_link_libraries(qsim_bin PRIVATE qsim_core)

# 3️⃣ Pybind11 module (opcional, só se o arquivo existir)
if(pybind11_FOUND AND EXISTS "${CMAKE_SOURCE_DIR}/python_bindings/pybind_module.cpp")
    pybind11_add_module(pyqsim python_bindings/pybind_module.cpp)
    target_link_libraries(pyqsim PRIVATE qsim_core)
endif()

# 4️⃣ Instalação
install(TARGETS qsim_bin qsim_core
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)
