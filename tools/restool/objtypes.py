class ObjectInfo:
    def __init__(self, name, static_properties, entity_properties):
        self.name = name
        self.static_properties = static_properties
        self.entity_properties = entity_properties


class ObjectTypeTool:
    def __init__(self):
        self.objs = []
        self.types_file = open('./game/res/objtypes.pas', 'w')

    def define_object(self, objInfo: ObjectInfo):
        self.objs.append(objInfo)

    def write_types(self, s):
        s = s.replace('\t', '  ')
        self.types_file.write(s + "\n")



    def define_objects(self):
        self.define_object(ObjectInfo(name="Player",
                                      static_properties=[
                                          ("playerStatic1", "integer"),
                                          ("playerStatic2", "integer")
                                      ],
                                      entity_properties=[
                                          ("player_state", "integer"),
                                      ]))

        self.define_object(ObjectInfo(name="Monster",
                                      static_properties=[
                                          ("monsterStatic1", "integer"),
                                          ("foo", "integer")
                                      ],
                                      entity_properties=[
                                          ("monsterInstance1", "integer"),
                                      ]))

    def generate_objtypes_pas(self):
        # Generate Pascal code

        def write(s):
            self.write_types(s)

        write("unit objtypes;")
        write("")  # {$H+}{$mode tp}
        write("interface")
        write("uses vect2d, res_enum, gtypes;")

        o: ObjectInfo
        for o in self.objs:
            write("type")
            # Write the object type
            write(f"\tObject{o.name} = record")
            write("\t\t{$i object.inc}")
            for prop in o.static_properties:
                write(f"\t\t{prop[0]}: {prop[1]};")
            write("\tend;")

            # Write the entity type

            write(f"\tEntity{o.name} = record")
            write("\t\t{$i entity.inc}")
            for prop in o.entity_properties:
                write(f"\t\t{prop[0]}: {prop[1]};")
            write("\tend;")

            write("")

            write(f'\tPEntity{o.name} = ^Entity{o.name};')

            write("")
            # write("var")
            # write(f'\tT{o.name}: Object{o.name};')
            write("")

        write('\tTObjectTypes = record')
        for o in self.objs:
            write(f'\t\t{o.name}: Object{o.name};')
        write('\tend;')

        write('var')
        write('\tObjectTypes: TObjectTypes;')

        write("implementation")
        write('begin')
        # write('\twriteln(\'objtypes.pas\');')
        write('\tFillChar(ObjectTypes, sizeof(TObjectTypes), 0);')
        write('end.')
        write("end.")

    def generate_reg_pas(self, filename, is_fpc):
        #   RegisterEntity(TPlayer, sizeof(ObjectPlayer), sizeof(EntityPlayer), Player_Stuff);
        with open(filename, "w") as myfile:
            def write(s):
                myfile.write(s + "\n")

            write('unit res_oreg;\n\ninterface\n')  # {$mode tp}{$H+}
            write('uses')
            write('\tobjtypes,')
            write('\tentity,')
            for o in self.objs:
                e = ';' if self.objs[-1] == o else ','
                write(f'\t{o.name}{e}')

            write('procedure RegisterObjectTypes;')

            write('implementation')
            write('procedure RegisterObjectTypes;')
            write('begin')

            for o in self.objs:
                ref = "@" if is_fpc else ""
                write(
                    f'\tRegisterEntity(@ObjectTypes.{o.name}, sizeof(Object{o.name}), sizeof(Entity{o.name}), {ref}{o.name}_Update);')

            write('end;')
            write('begin\nend.\n')

    def run(self):

        self.define_objects()
        self.generate_objtypes_pas()
        self.generate_reg_pas(filename='./game/res/dos/res_oreg.pas', is_fpc=False)
        self.generate_reg_pas(filename='./game/res/sdl/res_oreg.pas', is_fpc=True)

        self.types_file.close()

