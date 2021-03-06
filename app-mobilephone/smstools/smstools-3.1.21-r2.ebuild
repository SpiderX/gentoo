# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd tmpfiles toolchain-funcs

DESCRIPTION="Send and receive short messages through GSM modems"
HOMEPAGE="http://smstools3.kekekasvi.com/"
SRC_URI="
	http://smstools3.kekekasvi.com/packages/smstools3-${PV}.tar.gz
	https://dev.gentoo.org/~soap/distfiles/${P}-patches.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="stats"

DEPEND="
	acct-group/sms
	acct-user/smsd"
RDEPEND="${DEPEND}
	sys-process/procps
	stats? ( dev-libs/mm )"

PATCHES=(
	"${WORKDIR}"/${P}-gawk-location.patch
	"${WORKDIR}"/${P}-fno-common.patch
)

S="${WORKDIR}"/${PN}3

src_prepare() {
	default
	if use stats; then
		sed -i -e "s:CFLAGS += -D NOSTATS:#CFLAGS += -D NOSTATS:" \
			"${S}/src/Makefile" || die
	fi
	echo "CFLAGS += ${CFLAGS}" >> src/Makefile || die
}

src_compile() {
	emake -C src \
		CC="$(tc-getCC)" \
		LFLAGS="${LDFLAGS}"
}

src_install() {
	dobin src/smsd
	cd scripts || die
	dobin sendsms sms2html sms2unicode unicode2sms
	dobin hex2bin hex2dec email2sms
	dodoc mysmsd smsevent smsresend sms2xml sql_demo \
		smstest.php checkhandler-utf-8 eventhandler-utf-8 \
		forwardsms regular_run
	cd .. || die

	keepdir /var/spool/sms/{checked,incoming,outgoing}
	fowners -R smsd:sms /var/spool/sms
	fperms g+s /var/spool/sms/incoming

	newinitd "${FILESDIR}"/smsd.initd4 smsd
	insopts -o smsd -g sms -m0644
	insinto /etc
	newins examples/smsd.conf.easy smsd.conf
	dodoc -r doc

	systemd_dounit "${FILESDIR}"/smsd.service
	newtmpfiles "${FILESDIR}"/smsd.tmpfiles smsd.conf
}

pkg_postinst() {
	touch "${EROOT}"/var/log/smsd.log || die
	chown --no-dereference -f smsd:sms "${EROOT}"/var/log/smsd.log || die
}
