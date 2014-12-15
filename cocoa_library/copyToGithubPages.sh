if [[ "$OSTYPE" == "darwin"* ]]; then
	if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
		echo -e "Starting to update gh-pages\n"

		#copy data we're interested in to other place
		#cp -R coverage $HOME/coverage

		projectd=$(pwd)
		
		#go to home and setup git
		
		git config --global user.email "travis@travis-ci.org"
		git config --global user.name "Travis"

		#using token clone gh-pages branch
		git clone --quiet https://${GH_TOKEN}@github.com/Devisualization/Devisualization.github.io.git gh-pages > /dev/null

		#go into diractory and copy data we're interested in to that directory
		cd gh-pages
		mkdir -p Devisualization/Window
		
		toname1=$(date "%y/%m/%d")
		toname2=$(date "libdwc-osx-%h%m%s.a")
		
		mkdir -p Devisualization/Window/cocoa/${toname1}
		cp ${projectd}"/cocoa_library/bin/Debug/libdwc-osx.a" Devisualization/Window/cocoa/${toname1}"/"${toname2}
		
		if [!-f Devisualization/Window/cocoa/files.html]; then
			echo "<ul><li hidden>{FILE}</li></ul>" > Devisualization/Window/cocoa/files.html
		fi;
		sed -i "s/<li hidden>{FILE}</li>/<li hidden>{FILE}</li><li><a href=\"Devisualization/Window/cocoa/$toname1\"/\"$toname2\">"${toname1}" " ${toname2}"</a></li>/g"
		
		#add, commit and push files
		git add -f .
		git commit -m "Adding new build of Cocoa library for OSX by $TRAVIS_BUILD_NUMBER pushed to gh-pages"
		git push -fq origin gh-pages > /dev/null

		echo -e "Done magic with coverage\n"
	fi
fi