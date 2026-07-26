project('neo', 'c')

inc = include_directories(
    'src',
    'external/raylib',
)

libneo = static_library(
    'neo',
    sources: [
        'src/buffer.c',
        'src/neo.c'
        ],
    include_directories: inc,
    c_args: ['-DPLATFORM_DESKTOP'],
    install: true,
)

libneo_dep = declare_dependency(include_directories : inc,
                                   link_with : libneo)

libvm = static_library(
    'vm',
    sources: [
        'src/vm/vm.c',
    ],
    include_directories: include_directories(
        'src/',
        'src/vm'
    ),
    c_args: ['-DPLATFORM_DESKTOP'],
    install: true,
)

libvm_dep = declare_dependency(include_directories : inc,
                                link_with : [libneo, libvm])

libtext = static_library(
    'text',
    sources: [
        'src/text/text.c',
    ],
    include_directories: include_directories(
        'src/',
        'src/text',
        'external/raylib',
    ),
    c_args: ['-DPLATFORM_DESKTOP'],
    install: true,
)

libtext_dep = declare_dependency(include_directories : inc,
                               link_with : [libneo, libtext])

