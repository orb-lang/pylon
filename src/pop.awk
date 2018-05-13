BEGIN {
   FS = "[* (,);]+"
   print "struct " class " " Instance " = {"
}

{ print "    ." $2 " = &" $2  ","}

END {
   print "};"
}