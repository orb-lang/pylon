# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.10

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/Cellar/cmake/3.10.3/bin/cmake

# The command to remove a file.
RM = /usr/local/Cellar/cmake/3.10.3/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Users/atman/code/pylon/nano

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/atman/code/pylon/nano/build

# Include any dependencies generated for this target.
include CMakeFiles/iovec.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/iovec.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/iovec.dir/flags.make

CMakeFiles/iovec.dir/tests/iovec.c.o: CMakeFiles/iovec.dir/flags.make
CMakeFiles/iovec.dir/tests/iovec.c.o: ../tests/iovec.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/atman/code/pylon/nano/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object CMakeFiles/iovec.dir/tests/iovec.c.o"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/iovec.dir/tests/iovec.c.o   -c /Users/atman/code/pylon/nano/tests/iovec.c

CMakeFiles/iovec.dir/tests/iovec.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/iovec.dir/tests/iovec.c.i"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /Users/atman/code/pylon/nano/tests/iovec.c > CMakeFiles/iovec.dir/tests/iovec.c.i

CMakeFiles/iovec.dir/tests/iovec.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/iovec.dir/tests/iovec.c.s"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /Users/atman/code/pylon/nano/tests/iovec.c -o CMakeFiles/iovec.dir/tests/iovec.c.s

CMakeFiles/iovec.dir/tests/iovec.c.o.requires:

.PHONY : CMakeFiles/iovec.dir/tests/iovec.c.o.requires

CMakeFiles/iovec.dir/tests/iovec.c.o.provides: CMakeFiles/iovec.dir/tests/iovec.c.o.requires
	$(MAKE) -f CMakeFiles/iovec.dir/build.make CMakeFiles/iovec.dir/tests/iovec.c.o.provides.build
.PHONY : CMakeFiles/iovec.dir/tests/iovec.c.o.provides

CMakeFiles/iovec.dir/tests/iovec.c.o.provides.build: CMakeFiles/iovec.dir/tests/iovec.c.o


# Object files for target iovec
iovec_OBJECTS = \
"CMakeFiles/iovec.dir/tests/iovec.c.o"

# External object files for target iovec
iovec_EXTERNAL_OBJECTS =

iovec: CMakeFiles/iovec.dir/tests/iovec.c.o
iovec: CMakeFiles/iovec.dir/build.make
iovec: libnanomsg.a
iovec: CMakeFiles/iovec.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/atman/code/pylon/nano/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C executable iovec"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/iovec.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/iovec.dir/build: iovec

.PHONY : CMakeFiles/iovec.dir/build

CMakeFiles/iovec.dir/requires: CMakeFiles/iovec.dir/tests/iovec.c.o.requires

.PHONY : CMakeFiles/iovec.dir/requires

CMakeFiles/iovec.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/iovec.dir/cmake_clean.cmake
.PHONY : CMakeFiles/iovec.dir/clean

CMakeFiles/iovec.dir/depend:
	cd /Users/atman/code/pylon/nano/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/atman/code/pylon/nano /Users/atman/code/pylon/nano /Users/atman/code/pylon/nano/build /Users/atman/code/pylon/nano/build /Users/atman/code/pylon/nano/build/CMakeFiles/iovec.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/iovec.dir/depend

