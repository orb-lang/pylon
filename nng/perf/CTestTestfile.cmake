# CMake generated Testfile for 
# Source directory: /Users/atman/code/pylon/nng/perf
# Build directory: /Users/atman/code/pylon/nng/perf
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(inproc_lat "/Users/atman/code/pylon/nng/perf/inproc_lat" "64" "10000")
set_tests_properties(inproc_lat PROPERTIES  TIMEOUT "30")
add_test(inproc_thr "/Users/atman/code/pylon/nng/perf/inproc_thr" "1400" "10000")
set_tests_properties(inproc_thr PROPERTIES  TIMEOUT "30")
