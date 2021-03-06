# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{6..9} pypy3)

inherit distutils-r1

DESCRIPTION="Collection of small Python functions & classes"
HOMEPAGE="https://pypi.org/project/python-utils/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="dev-python/six[${PYTHON_USEDEP}]"

distutils_enable_tests pytest

PATCHES=(
	"${FILESDIR}"/python-utils-2.5.0-no-install-tests.patch
)

python_prepare_all() {
	find . -name '__pycache__' -prune -exec rm -r {} + || die "Cleaning __pycache__ failed"
	find . -name '*.pyc' -delete || die "Cleaning *.pyc failed"
	sed -i -e '/--cov/d' -e '/--flake8/d' pytest.ini || die
	distutils-r1_python_prepare_all
}
