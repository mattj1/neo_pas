class Tileset:

    def __init__(self, name) -> None:
        super().__init__()
        self.name = name


class SpriteInfo:

    def __init__(self, sprite_state, direction: int) -> None:
        self.sprite_state = sprite_state
        self.direction = direction

        self.src_rect = (0, 0, 0, 0)
        self.offset = (0, 0)

        self.use_direction = -1

    def name(self):
        return f'{self.sprite_state.name}_{self.direction}'


class SpriteState:

    def __init__(self, name) -> None:
        super().__init__()

        self.name = f'SPRITE_{name}'

        self.sprite_infos = [SpriteInfo(self, 0), SpriteInfo(self, 1), SpriteInfo(self, 2), SpriteInfo(self, 3)]


class EntityState:
    def init(self):
        pass


class ResTool:

    def __init__(self) -> None:
        super().__init__()

        self.tilesets: [Tileset] = []
        self.sprite_states: [SpriteState] = []
        self.entity_states = []

        self.current_sprite_state: SpriteState = None

        self.num_sprite_infos = 0

    def tileset(self, filename, name):
        t = Tileset(name)
        self.tilesets.append(t)

    def sprite_state(self, name):
        self.current_sprite_state = SpriteState(name)
        self.sprite_states.append(self.current_sprite_state)

    def sprite_info(self, direction, src_rect, offset):
        sprite_info = self.current_sprite_state.sprite_infos[direction]
        sprite_info.src_rect = src_rect
        sprite_info.offset = offset

    def sprite_info_use(self, direction, use_direction):
        sprite_info = self.current_sprite_state.sprite_infos[direction]

        # For now, a new sprite info identifier won't be used if we're re-using directions,
        # since there's no support for flipping sprites, etc...
        sprite_info.use_direction = use_direction

    def write_enums(self, filename):

        with open(filename, 'w') as myfile:
            def w(_s):
                myfile.write(f'{_s}\n')

            w("{ AUTO-GENERATED }\n")
            w("unit res_enum;\n")
            w("interface\n")
            w('type')
            w("\tspriteInfo = (")

            is_first = True
            for ss in self.sprite_states:
                for si in ss.sprite_infos:
                    # print(si)
                    if si.use_direction == -1:
                        if not is_first:
                            myfile.write(',\n')

                        is_first = False

                        print(si.name(), si.use_direction)

                        myfile.write(f'\t\t{si.name()}')

                        self.num_sprite_infos += 1
            w('\n\t);')
            w('')

            w("\tspriteState = (")
            ss: SpriteState
            for ss in self.sprite_states:
                s = f'\t\t{ss.name}'
                if ss != self.sprite_states[-1]:
                    s += ','
                w(s)
            w("\t);")
            w('')

            w('\tentityState = (')
            for es in self.entity_states:
                s = f'\t\tSTATE_{es[0]}'
                if es != self.entity_states[-1]:
                    s += ","
                w(s)
            w('\t);')
            w('')

            w('implementation')
            w('end.')

    def write_res(self, filename, is_fpc=True):

        with open(filename, "w") as myfile:
            def w(s):
                myfile.write(f'{s}\n')

            w("{ AUTO-GENERATED }\n")
            w("unit res;\n")
            w("{$F+}")
            w('interface\n')
            w('uses gtypes, res_enum;\n')

            w('const')

            w(f'\tsprite_infos: array[0..{self.num_sprite_infos - 1}] of sprite_info_t = (')
            for ss in self.sprite_states:
                for si in ss.sprite_infos:
                    # print(si)
                    if si.use_direction == -1:
                        w(f'\t\t{{ {si.name()} }}')
                        s = f'\t\t(' \
                            f'offsX: {si.offset[0]}; ' \
                            f'offsY: {si.offset[1]}; ' \
                            f'srcX: {si.src_rect[0]}; ' \
                            f'srcY: {si.src_rect[1]}; ' \
                            f'Width: {si.src_rect[2]}; ' \
                            f'Height: {si.src_rect[3]})'

                        if ss != self.sprite_states[-1]:
                            s += ','
                        w(s)
            w('\t);')
            w('')
            w(f'\tsprite_states: array[0..{len(self.sprite_states) - 1}] of sprite_state_t = (')
            for ss in self.sprite_states:
                w(f'\t\t{{ {ss.name} }}')
                si_list = []
                for si in ss.sprite_infos:
                    if si.use_direction == -1:
                        si_list.append(si)
                    else:
                        si_list.append(ss.sprite_infos[si.use_direction])

                s = f'\t\t( sprites: ({si_list[0].name()}, {si_list[1].name()}, {si_list[2].name()}, {si_list[3].name()});' \
                    f' tileSet: 0 )'

                if ss != self.sprite_states[-1]:
                    s += ','

                w(s)
            w('\t);')
            w('')
            w(f'\tentity_states: array[0..{len(self.entity_states) - 1}] of entity_state_t = (')
            for es in self.entity_states:
                def adjust_proc(proc):
                    if proc == 'nil':
                        return proc

                    if is_fpc:
                        return f'@{proc}'

                    return proc

                s = '\t\t(\n'
                s += f'\t\tstate: STATE_{es[0]};\n'
                s += f'\t\tnextState: STATE_{es[1]};\n'
                s += f'\t\tnumFrames: {es[2]}; \n'
                s += f'\t\tonStateProc: {adjust_proc(es[3])}; \n'
                s += f'\t\tonFrameProc: {adjust_proc(es[4])}; \n'
                s += f'\t\tspriteState_: SPRITE_{es[5]} \n'
                s += '\t\t)'
                if es != self.entity_states[-1]:
                    s += ','
                w(s)
            w('\t);')

            w("implementation\nend.")

    def run(self):
        self.tileset("tileset.bmp", "MAIN")

        self.sprite_state("NONE")
        self.sprite_info(direction=0, src_rect=(0, 0, 0, 0), offset=(0, 0))
        self.sprite_info_use(direction=1, use_direction=0)
        self.sprite_info_use(direction=2, use_direction=0)
        self.sprite_info_use(direction=3, use_direction=0)

        self.sprite_state("PLAYER0")
        self.sprite_info(direction=0, src_rect=(0, 0, 16, 32), offset=(0, 0))
        self.sprite_info_use(direction=1, use_direction=0)
        self.sprite_info_use(direction=2, use_direction=0)
        self.sprite_info_use(direction=3, use_direction=0)

        self.sprite_state("PLAYER1")
        self.sprite_info(direction=0, src_rect=(16, 0, 16, 32), offset=(0, 0))
        self.sprite_info_use(direction=1, use_direction=0)
        self.sprite_info_use(direction=2, use_direction=0)
        self.sprite_info_use(direction=3, use_direction=0)

        self.entity_states.append(['NONE', 'NONE', 60, 'nil', 'nil', 'NONE'])
        self.entity_states.append(['PLAYER0', 'PLAYER1', 20, 'nil', 'nil', 'PLAYER0'])
        self.entity_states.append(['PLAYER1', 'PLAYER0', 20, 'nil', 'nil', 'PLAYER1'])

        # write the resource files
        self.write_enums(filename='../../game/res_enum.pas')

        self.write_res(filename="../../game/sdl/res.pas", is_fpc=True)
        self.write_res(filename='../../game/dos/res.pas', is_fpc=False)


if __name__ == '__main__':
    ResTool().run()
