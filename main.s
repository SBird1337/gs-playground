.gba
.thumb
.open "roms/AGFE.gba","build/test.gba", 0x08000000

.org 0x08197AA0
    .word RenderTest|1

.org 0x09000000
.importobj "build/linked.o"
