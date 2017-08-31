#!/bin/sh
set -x
set -e

clear
echo

if [ "$SPHINX_BUILD_FROM_SOURCE" ]; then

	# Set temp environment vars
	export VCS_PROJECT_URI=${VCS_PROJECT_URI:-"github.com/sphinxsearch/sphinx"}
	export VCS_PROJECT_BRANCH=${VCS_PROJECT_BRANCH:-"master"}
	export VCS_PROJECT_CLONE_PATH=${VCS_PROJECT_CLONE_PATH:-"/tmp/sphinxsearch"}
	export VCS_PROJECT_CLONE_DEPTH=${VCS_PROJECT_CLONE_DEPTH:-"1"}
	export VCS_PROJECT_CMAKE_ARGS=${VCS_PROJECT_CMAKE_ARGS:-"-DWITH_EXPAT=OFF -DWITH_MYSQL=ON -DWITH_PGSQL=OFF -DUSE_BISON=ON -DUSE_FLEX=ON -DWITH_RE2=ON -DWITH_STEMMER=OFF"}
	export VCS_PROJECT_CONFIGURE_ARGS=${VCS_PROJECT_CONFIGURE_ARGS:-"--with-mysql --with-pgsql"} # --without-mysql
	export VCS_PROJECT_CONFIGURE_PREFIX=${VCS_PROJECT_CONFIGURE_PREFIX:-"/usr/local/sphinx"} # --without-mysql

	export PKG_CONFIG_PATH="/usr/lib/pkgconfig/:/usr/local/lib/pkgconfig/"

	# Install build deps
	apk add --update --no-cache --no-progress --virtual build-deps ${APK_BUILD}

	# Compile & Install libgit2 (v0.23)
	git clone -b ${VCS_PROJECT_BRANCH} --depth ${VCS_PROJECT_CLONE_DEPTH} -- https://${VCS_PROJECT_URI} ${VCS_PROJECT_CLONE_PATH}

	mkdir -p ${VCS_PROJECT_CLONE_PATH}/build
	cd ${VCS_PROJECT_CLONE_PATH}/build

	# cd ${VCS_PROJECT_CLONE_PATH}
	# ./configure --prefix=${VCS_PROJECT_CONFIGURE_PREFIX} ${VCS_PROJECT_CONFIGURE_ARGS}
	# make install

	cmake ${VCS_PROJECT_CMAKE_ARGS} ..
	cmake --build . --target install

	# Cleanup
	rm -r ${VCS_PROJECT_CLONE_PATH}

	# Remove build deps
	apk --no-cache --no-progress del build-deps

fi