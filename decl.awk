# pre-process with `sed -e "s/(/ (/"`

{
   Type = $1
   Fn = $2

   if (substr(Fn, 0, 1) == "*") {
      Paren = " *("
   } else {
      Paren = " (*"
   }

   $1=$2=""

   print "    " Type Paren Fn ")" substr($0,3)
}