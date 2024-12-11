# https://mesonbuild.com/External-Project-module.html

project('vulkan', 'cpp')

cmake = import('cmake')

cpu = host_machine.cpu()
if cpu == 'amd64'
    arch = 'x86_64'
elif cpu == 'arm64'
    arch = 'arm64'
endif

options = cmake.subproject_options()
options.add_cmake_defines({
    'CMAKE_OSX_ARCHITECTURES': arch,
    'CMAKE_OSX_SYSROOT': meson.get_cross_property('cmake_osx_sysroot'),
    'CMAKE_BUILD_TYPE': 'Release',
    'UPDATE_DEPS': 'ON',
    'USE_GAS': 'ON',
})

vulkan_proj = cmake.subproject('vulkan', options: options)
vulkan_dep = vulkan_proj.dependency('vulkan')
meson.override_dependency('vulkan', vulkan_dep)
