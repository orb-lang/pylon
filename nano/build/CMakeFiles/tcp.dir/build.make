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
include CMakeFiles/tcp.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/tcp.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/tcp.dir/flags.make

CMakeFiles/tcp.dir/tests/tcp.c.o: CMakeFiles/tcp.dir/flags.make
CMakeFiles/tcp.dir/tests/tcp.c.o: ../tests/tcp.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/atman/code/pylon/nano/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object CMakeFiles/tcp.dir/tests/tcp.c.o"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/tcp.dir/tests/tcp.c.o   -c /Users/atman/code/pylon/nano/tests/tcp.c

CMakeFiles/tcp.dir/tests/tcp.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/tcp.dir/tests/tcp.c.i"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /Users/atman/code/pylon/nano/tests/tcp.c > CMakeFiles/tcp.dir/tests/tcp.c.i

CMakeFiles/tcp.dir/tests/tcp.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/tcp.dir/tests/tcp.c.s"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /Users/atman/code/pylon/nano/tests/tcp.c -o CMakeFiles/tcp.dir/tests/tcp.c.s

CMakeFiles/tcp.dir/tests/tcp.c.o.requires:

.PHONY : CMakeFiles/tcp.dir/tests/tcp.c.o.requires

CMakeFiles/tcp.dir/tests/tcp.c.o.provides: CMakeFiles/tcp.dir/tests/tcp.c.o.requires
	$(MAKE) -f CMakeFiles/tcp.dir/build.make CMakeFiles/tcp.dir/tests/tcp.c.o.provides.build
.PHONY : CMakeFiles/tcp.dir/tests/tcp.c.o.provides

CMakeFiles/tcp.dir/tests/tcp.c.o.provides.build: CMakeFiles/tcp.dir/tests/tcp.c.o


# Object files for target tcp
tcp_OBJECTS = \
"CMakeFiles/tcp.dir/tests/tcp.c.o"

# External object files for target tcp
tcp_EXTERNAL_OBJECTS =

tcp: CMakeFiles/tcp.dir/tests/tcp.c.o
tcp: CMakeFiles/tcp.dir/build.make
tcp: libnanomsg.a
tcp: CMakeFiles/tcp.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/atman/code/pylon/nano/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C executable tcp"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/tcp.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/tcp.dir/build: tcp

.PHONY : CMakeFiles/tcp.dir/build

CMakeFiles/tcp.dir/requires: CMakeFiles/tcp.dir/tests/tcp.c.o.requires

.PHONY : CMakeFiles/tcp.dir/requires

CMakeFiles/tcp.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/tcp.dir/cmake_clean.cmake
.PHONY : CMakeFiles/tcp.dir/clean

CMakeFiles/tcp.dir/depend:
	cd /Users/atman/code/pylon/nano/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/atman/code/pylon/nano /Users/atman/code/pylon/nano /Users/atman/code/pylon/nano/build /Users/atman/code/pylon/nano/build /Users/atman/code/pylon/nano/build/CMakeFiles/tcp.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/tcp.dir/depend

