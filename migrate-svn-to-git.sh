#!/bin/bash
# Migrate SVN to GIT using SVN clone, does not use dump file

# Variables
AUTHORS="authors.txt"
SVNREPO="svn://hostname/path"
DESTDIR="/dest/dir"
GITHOST="url-or-ip-address"
GITHOSTPORT="port"
GITREPO="path/to/git/repo"

# Pause
function pause(){
	read -p "Press any key to continue..."
	echo
}

# How does this get created without the SVN repo being cloned
if ! [ -s "$AUTHORS" ]; then
	echo "Creating an authors txt file for mapping SVN users to GIT"
	svn log --xml | grep author | sort -u | perl -pe 's/.*>(.*?)<.*/$1 = /' >> $AUTHORS
else
	echo "Authors file already exists:"
	echo
fi

cat $AUTHORS
pause

echo "Now pulling the SVN data from the repo"
git svn clone --stdlayout --authors-file=$AUTHORS $SVNREPO $DESTDIR

git svn clone $SVNREPO $DESTDIR -A $AUTHORS -t tags -b branches -T trunk

cd $DESTDIR
git svn fetch

git remote add origin ssh://git@"$GITHOST":"$GITHOSTPORT"/"$GITREPO"
git push origin master

echo "Migration Completed!"