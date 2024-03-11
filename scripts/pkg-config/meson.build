# https://mesonbuild.com/External-Project-module.html

project('pkg-config', 'c')

mod = import('unstable-external_project')

p = mod.add_project('configure',
    configure_options : [
        '--prefix=@PREFIX@',
        '--disable-static',
        '--enable-fast-instal=true',
        '--disable-dependency-tracking',
        '--with-pic',
        '--with-aix-soname=aix',
        '--without-gnu-ld',
        '--with-internal-glib',
        '--without-gcov',
        # clang 15 has an error about int-conversion, treat it as warning
        'CFLAGS=-Wno-error=int-conversion',
    ],
    verbose: true,
)

pkg_config_dep = p.dependency('pkg-config')
meson.override_dependency('pkg-config', pkg_config_dep)
