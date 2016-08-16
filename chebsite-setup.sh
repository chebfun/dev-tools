#!/bin/bash
# chebsite-setup.sh:  Set up workspace for Chebfun website development.
#     Based on/ported from Hrothgar's chebsite_setup.m.
# Written By:  Anthony P. Austin, May 4, 2016.

die()
{
	if [ $# -gt 0 ] ; then
		echo "${1}"
	fi

	echo "Aborting."
	exit 1
}

get_permission_to_continue()
{
	local REPLY=""
	while read -ep "> " REPLY ; do
		case "${REPLY}" in
			[Yy]) break ;;
			[Nn]) die ;;
		esac
	done
}

################################################################################

cat <<EOF
First navigate to where you want the Chebfun website's folder to be located.
Then run this script from there. For example, to set up the site at
~/my_folder/chebsite, copy this script into "my_folder".  Note that this script
will also clone the examples and guide repos.

Your current location is ${PWD}.

Do you wish to set up the site here?  [Y/N]
EOF

get_permission_to_continue

# Check for a few needed utilities.  Of these, only the check for pip is likely
# to fail on Linux and/or OS X.  On Cygwin, the likelihood of missing Git or
# Python is higher.
if ! command -v git &> /dev/null ; then
	cat <<EOF
Could not find Git.  Please install Git before proceeding with setup.
EOF
	exit 1
elif ! command -v python &> /dev/null ; then
	cat <<EOF
Could not find Python.  The website scripts require Python to run.  Please
install Python before proceeding with setup.
EOF
	exit 1
elif ! command -v pip &> /dev/null ; then
	cat <<EOF
Could not find the 'pip' package manager for Python.  Please install pip before
proceeding with setup.

(Hint:  On OS X, 'sudo easy_install pip' should do the trick.)
EOF
	exit 1
fi

# Clone the various repositories.
mkdir chebsite || die "Could not make directory chebsite/."
git clone https://github.com/chebfun/chebsite.git chebsite \
	|| die "Could not clone chebsite repository."

mkdir 'chebsite/_build' || die "Could not make directory chebsite/_build/."
git clone https://github.com/chebfun/chebfun.github.io.git "chebsite/_build" \
	|| die "Could not clone chebfun.github.io repository."

mkdir examples || die "Could not make directory examples/."
git clone https://github.com/chebfun/examples.git examples \
	|| die "Could not clone examples repository."

mkdir guide || die "Could not make directory guide/."
git clone https://github.com/chebfun/guide.git guide \
	|| die "Could not clone guide repository."

# Install the needed Python modules.
#
# NB:  The "wheel" package needs to be installed/upgraded first.
pip install --user --upgrade wheel
pip install --user MarkupSafe Jinja2 PyYAML Markdown

# Need to handle the python_dateutil module a little differently, as it's
# typically installed with the system Python distribution.  We need to install
# it if it's not present and upgrade it if it's present but out-of-date.
if ! python -c "import dateutil" &> /dev/null ; then
	pip install --user python_dateutil
else
	DU_VER=$(python -c "import dateutil; print(dateutil.__version__)")
	if [ $(echo "${DU_VER}" | cut -d '.' -f 1) -le 1 ] ; then
		cat <<EOF
The installed version of the 'python_dateutil' Python module is ${DU_VER}.  The
website build scripts require this module to be v2.0 or later.

If this module comes packaged with your Python installation, it is best to
upgrade it by upgrading Python.  This may not be possible if you are running on
a system on which you do not have administrative privileges.  In this case, or
if you would prefer, we can install an upgraded version in your home directory
instead.

Install upgraded python_dateutil module in home directory?  [Y/N]
EOF
		get_permission_to_continue
		pip install --upgrade --user python_dateutil
	fi
fi
