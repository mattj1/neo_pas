# neo_pas

Pascal game framework for MS-DOS

Code is meant to compile with:
* Turbo Pascal
* FreePascal in FPC mode (-mfpc, NOT -mobjfpc)
  * This ensures the Integer type is 16-bit

Main module:
* neo.lpr

Tested and runs on:
* DOSBox
* Windows
* MacOS

Note: We could probably use TP compatibility for non-DOS targets if we're willing to sacrifice inline procedures.

# Building and running with Borland Pascal 7

The required command line arguments are in bpc.cfg.

```
# With 'bpc' in your PATH:

# Compile the project
bpc

# Run
neo
```

# Building and running with FreePascal

The required command line arguments are in fpc.cfg
(Note: Currently has several arguments specific to MacOS)
```
# Compile the project
fpc neo.lpr

# Run
./neo
```
