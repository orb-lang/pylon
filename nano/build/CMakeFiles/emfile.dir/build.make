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
include CMakeFiles/emfile.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/emfile.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/emfile.dir/flags.make

CMakeFiles/emfile.dir/tests/emfile.c.o: CMakeFiles/emfile.dir/flags.make
CMakeFiles/emfile.dir/tests/emfile.c.o: ../tests/emfile.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/atman/code/pylon/nano/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building C object CMakeFiles/emfile.dir/tests/emfile.c.o"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/emfile.dir/tests/emfile.c.o   -c /Users/atman/code/pylon/nano/tests/emfile.c

CMakeFiles/emfile.dir/tests/emfile.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/emfile.dir/tests/emfile.c.i"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /Users/atman/code/pylon/nano/tests/emfile.c > CMakeFiles/emfile.dir/tests/emfile.c.i

CMakeFiles/emfile.dir/tests/emfile.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/emfile.dir/tests/emfile.c.s"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /Users/atman/code/pylon/nano/tests/emfile.c -o CMakeFiles/emfile.dir/tests/emfile.c.s

CMakeFiles/emfile.dir/tests/emfile.c.o.requires:

.PHONY : CMakeFiles/emfile.dir/tests/emfile.c.o.requires

CMakeFiles/emfile.dir/tests/emfile.c.o.provides: CMakeFiles/emfile.dir/tests/emfile.c.o.requires
	$(MAKE) -f CMakeFiles/emfile.dir/build.make CMakeFiles/emfile.dir/tests/emfile.c.o.provides.build
.PHONY : CMakeFiles/emfile.dir/tests/emfile.c.o.provides

CMakeFiles/emfile.dir/tests/emfile.c.o.provides.build: CMakeFiles/emfile.dir/tests/emfile.c.o


# Object files for target emfile
emfile_OBJECTS = \
"CMakeFiles/emfile.dir/tests/emfile.c.o"

# External object files for target emfile
emfile_EXTERNAL_OBJECTS =

emfile: CMakeFiles/emfile.dir/tests/emfile.c.o
emfile: CMakeFiles/emfile.dir/build.make
emfile: libnanomsg.a
emfile: CMakeFiles/emfile.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/atman/code/pylon/nano/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking C executable emfile"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/emfile.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/emfile.dir/build: emfile

.PHONY : CMakeFiles/emfile.dir/build

CMakeFiles/emfile.dir/requires: CMakeFiles/emfile.dir/tests/emfile.c.o.requires

.PHONY : CMakeFiles/emfile.dir/requires

CMakeFiles/emfile.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/emfile.dir/cmake_clean.cmake
.PHONY : CMakeFiles/emfile.dir/clean

CMakeFiles/emfile.dir/depend:
	cd /Users/atman/code/pylon/nano/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/atman/code/pylon/nano /Users/atman/code/pylon/nano /Users/atman/code/pylon/nano/build /Users/atman/code/pylon/nano/build /Users/atman/code/pylon/nano/build/CMakeFiles/emfile.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/emfile.dir/depend

