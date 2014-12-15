if [[ "$OSTYPE" == "darwin"* ]]; then
	echo -e "Compiling OSX lib"
	
	xctool -project cocoa_library/project/dwc-osx.xcodeproj -scheme dwc-osx
	
	echo -e "Done compiling OSX lib"
fi