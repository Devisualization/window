parse.sh Generates WindowsAPI bindings from MingX x64 headers.

$ ./parse.sh windows.h
$ mv windows.h.d windows.d

Required:
Bash
Awk
Sed






===============================
FOR DWC:
The output from the above commands was manually parsed and split into two files.
windows.di is the interface files without macro expansion.
windows_impl.d is the macros aka functions.