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
include CMakeFiles/surveyttl.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/surveyttl.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/surveyttl.dir/flags.make

CMakeFiles/surveyttl.dir/tests/surveyttl.c.o: CMakeFiles/surveyttl.dir/flags.make
CMakeFiles/surveyttl.dir/tests/surveyttl.c.o: ../tests/surveyttl.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/atman/code/pylon/nano/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object CMakeFiles/surveyttl.dir/tests/surveyttl.c.o"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/surveyttl.dir/tests/surveyttl.c.o   -c /Users/atman/code/pylon/nano/tests/surveyttl.c

CMakeFiles/surveyttl.dir/tests/surveyttl.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/surveyttl.dir/tests/surveyttl.c.i"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /Users/atman/code/pylon/nano/tests/surveyttl.c > CMakeFiles/surveyttl.dir/tests/surveyttl.c.i

CMakeFiles/surveyttl.dir/tests/surveyttl.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/surveyttl.dir/tests/surveyttl.c.s"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /Users/atman/code/pylon/nano/tests/surveyttl.c -o CMakeFiles/surveyttl.dir/tests/surveyttl.c.s

CMakeFiles/surveyttl.dir/tests/surveyttl.c.o.requires:

.PHONY : CMakeFiles/surveyttl.dir/tests/surveyttl.c.o.requires

CMakeFiles/surveyttl.dir/tests/surveyttl.c.o.provides: CMakeFiles/surveyttl.dir/tests/surveyttl.c.o.requires
	$(MAKE) -f CMakeFiles/surveyttl.dir/build.make CMakeFiles/surveyttl.dir/tests/surveyttl.c.o.provides.build
.PHONY : CMakeFiles/surveyttl.dir/tests/surveyttl.c.o.provides

CMakeFiles/surveyttl.dir/tests/surveyttl.c.o.provides.build: CMakeFiles/surveyttl.dir/tests/surveyttl.c.o


# Object files for target surveyttl
surveyttl_OBJECTS = \
"CMakeFiles/surveyttl.dir/tests/surveyttl.c.o"

# External object files for target surveyttl
surveyttl_EXTERNAL_OBJECTS =

surveyttl: CMakeFiles/surveyttl.dir/tests/surveyttl.c.o
surveyttl: CMakeFiles/surveyttl.dir/build.make
surveyttl: libnanomsg.a
surveyttl: CMakeFiles/surveyttl.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/atman/code/pylon/nano/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C executable surveyttl"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/surveyttl.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/surveyttl.dir/build: surveyttl

.PHONY : CMakeFiles/surveyttl.dir/build

CMakeFiles/surveyttl.dir/requires: CMakeFiles/surveyttl.dir/tests/surveyttl.c.o.requires

.PHONY : CMakeFiles/surveyttl.dir/requires

CMakeFiles/surveyttl.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/surveyttl.dir/cmake_clean.cmake
.PHONY : CMakeFiles/surveyttl.dir/clean

CMakeFiles/surveyttl.dir/depend:
	cd /Users/atman/code/pylon/nano/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/atman/code/pylon/nano /Users/atman/code/pylon/nano /Users/atman/code/pylon/nano/build /Users/atman/code/pylon/nano/build /Users/atman/code/pylon/nano/build/CMakeFiles/surveyttl.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/surveyttl.dir/depend

