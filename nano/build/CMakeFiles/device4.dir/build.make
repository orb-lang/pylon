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
include CMakeFiles/device4.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/device4.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/device4.dir/flags.make

CMakeFiles/device4.dir/tests/device4.c.o: CMakeFiles/device4.dir/flags.make
CMakeFiles/device4.dir/tests/device4.c.o: ../tests/device4.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/atman/code/pylon/nano/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object CMakeFiles/device4.dir/tests/device4.c.o"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/device4.dir/tests/device4.c.o   -c /Users/atman/code/pylon/nano/tests/device4.c

CMakeFiles/device4.dir/tests/device4.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/device4.dir/tests/device4.c.i"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /Users/atman/code/pylon/nano/tests/device4.c > CMakeFiles/device4.dir/tests/device4.c.i

CMakeFiles/device4.dir/tests/device4.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/device4.dir/tests/device4.c.s"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /Users/atman/code/pylon/nano/tests/device4.c -o CMakeFiles/device4.dir/tests/device4.c.s

CMakeFiles/device4.dir/tests/device4.c.o.requires:

.PHONY : CMakeFiles/device4.dir/tests/device4.c.o.requires

CMakeFiles/device4.dir/tests/device4.c.o.provides: CMakeFiles/device4.dir/tests/device4.c.o.requires
	$(MAKE) -f CMakeFiles/device4.dir/build.make CMakeFiles/device4.dir/tests/device4.c.o.provides.build
.PHONY : CMakeFiles/device4.dir/tests/device4.c.o.provides

CMakeFiles/device4.dir/tests/device4.c.o.provides.build: CMakeFiles/device4.dir/tests/device4.c.o


# Object files for target device4
device4_OBJECTS = \
"CMakeFiles/device4.dir/tests/device4.c.o"

# External object files for target device4
device4_EXTERNAL_OBJECTS =

device4: CMakeFiles/device4.dir/tests/device4.c.o
device4: CMakeFiles/device4.dir/build.make
device4: libnanomsg.a
device4: CMakeFiles/device4.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/atman/code/pylon/nano/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C executable device4"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/device4.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/device4.dir/build: device4

.PHONY : CMakeFiles/device4.dir/build

CMakeFiles/device4.dir/requires: CMakeFiles/device4.dir/tests/device4.c.o.requires

.PHONY : CMakeFiles/device4.dir/requires

CMakeFiles/device4.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/device4.dir/cmake_clean.cmake
.PHONY : CMakeFiles/device4.dir/clean

CMakeFiles/device4.dir/depend:
	cd /Users/atman/code/pylon/nano/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/atman/code/pylon/nano /Users/atman/code/pylon/nano /Users/atman/code/pylon/nano/build /Users/atman/code/pylon/nano/build /Users/atman/code/pylon/nano/build/CMakeFiles/device4.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/device4.dir/depend

