class ObjectInfo:
    def __init__(self, name, static_properties, entity_properties):
        self.name = name
        self.static_properties = static_properties
        self.entity_properties = entity_properties


objs = []


def define_object(objInfo: ObjectInfo):
    objs.append(objInfo)


def write_types(s):
    s = s.replace('\t', '  ')
    types_file.write(s + "\n")


def write_reg(s):
    reg_file.write(s + "\n")


def define_objects():
    define_object(ObjectInfo(name="Player",
                             static_properties=[
                                 ("playerStatic1", "integer"),
                                 ("playerStatic2", "integer")
                             ],
                             entity_properties=[
                                 ("instanceStuff1", "integer"),
                                 ("instanceStuff2", "integer")
                             ]))

    define_object(ObjectInfo(name="Monster",
                             static_properties=[
                                 ("monsterStatic1", "integer"),
                                 ("foo", "integer")
                             ],
                             entity_properties=[
                                 ("monsterInstance1", "integer"),
                             ]))


def run():
    # Generate Pascal code

    def write(s):
        write_types(s)

    write("unit objtypes;")
    write("{$mode tp}{$H+}")
    write("interface")

    o: ObjectInfo
    for o in objs:
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
        write("var")
        write(f'\tT{o.name}: ^Object{o.name};')
        write("")

    write("implementation")
    write("end.")


def run_registration():
    #   RegisterEntity(TPlayer, sizeof(ObjectPlayer), sizeof(EntityPlayer), Player_Stuff);

    def write(s):
        write_reg(s)

    write('unit res_oreg;\n{$mode tp}{$H+}\ninterface\n')
    write('uses')
    write('\tobjtypes,')
    write('\tentity,')
    for o in objs:
        e = ';' if objs[-1] == o else ','
        write(f'\t{o.name}{e}')

    write('procedure RegisterObjectTypes;')

    write('implementation')
    write('procedure RegisterObjectTypes;')
    write('begin')

    for o in objs:
        write(f'\tRegisterEntity(T{o.name}, sizeof(Object{o.name}), sizeof(Entity{o.name}), {o.name}_Stuff);')

    write('end;')
    write('begin\nend.\n')


if __name__ == '__main__':
    types_file = open('res/objtypes.pas', 'w')
    reg_file = open('res/res_oreg.pas', "w")

    define_objects()

    run()

    run_registration()

    types_file.close()
    reg_file.close()
