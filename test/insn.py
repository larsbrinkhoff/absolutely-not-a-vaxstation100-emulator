#!/usr/bin/env python3

import os
import json
import subprocess

# ABCD ADDA.l ADDA.w ADD.b ADD.l ADD.w ADDX.b ADDX.l ADDX.w AND.b ANDItoCCR ANDItoSR
# AND.l AND.w ASL.b ASL.l ASL.w ASR.b ASR.l ASR.w Bcc BCHG BCLR BSET BSR BTST CHK
# CLR.b CLR.l CLR.w CMPA.l CMPA.w CMP.b CMP.l CMP.w DBcc DIVS DIVU EOR.b EORItoCCR EORItoSR
# EOR.l EOR.w EXG EXT.l EXT.w JMP JSR LEA LINK LSL.b LSL.l LSL.w LSR.b LSR.l LSR.w 
# MOVEA.l MOVEA.w MOVE.b MOVEfromSR MOVEfromUSP MOVE.l MOVEM.l MOVEM.w MOVEP.l MOVEP.w
# MOVE.q MOVEtoCCR MOVEtoSR MOVEtoUSP MOVE.w MULS MULU NBCD NEG.b NEG.l NEG.w 
# NEGX.b NEGX.l NEGX.w NOP NOT.b NOT.l NOT.w OR.b ORItoCCR ORItoSR OR.l OR.w PEA RESET
# ROL.b ROL.l ROL.w ROR.b ROR.l ROR.w ROXL.b ROXL.l ROXL.w ROXR.b ROXR.l ROXR.w
# RTE RTR RTS SBCD Scc SUBA.l SUBA.w SUB.b SUB.l SUB.w SUBX.b SUBX.l SUBX.w SWAP
# TAS TRAP TRAPV TST.b TST.l TST.w UNLINK

#tests = ["ADDA.l", "ADDA.w", "ADD.b", "ADD.l", "ADD.w"]
#tests = ["AND.b", "AND.l", "AND.w"]
#tests = ["ANDItoCCR", "ANDItoSR", "EORItoCCR", "EORItoSR",
#          "MOVEtoCCR", "MOVEtoSR", "ORItoCCR", "ORItoSR"]        nok
#tests = ["ASL.b", "ASL.w", "ASL.l", "ASR.b", "ASR.w", "ASR.l"]   nok
#tests = ["Bcc", "BSR"]
#tests = ["BCHG", "BCLR", "BSET", "BTST"]
#tests = ["CLR.b", "CLR.w", "CLR.l"]
tests = ["CMPA.w", "CMPA.l", "CMP.b", "CMP.w", "CMP.l"]
#DBcc Scc
#DIVS DIVU
#EOR OR
#EXCG EXT
#JMP JSR
#LEA PEA
#LSL LSR
#MOVEA MOVE MOVEM MOVE.q
#MULS MULU
#NEG NOP NOT
#ROL ROR
#RTE RTR RTS
#SUBA SUB
#SWAP TRAP TRAPV
#TST

name = ""
initial = ""
final = ""
prefetch = ""
iram = ""
fram = ""
count = 0

def sp(data):
    if (data['sr'] & 0x2000) == 0:
        return str(data['usp'])
    else:
        return str(data['ssp'])

def check(data):
    global name, initial, final, prefetch, iram, fram, count
    print("Test name " + data['name'])
    count += 1
    name += "  \"%s\",\n" % data['name']
    x = "  {"
    for i in ["d0", "d1", "d2", "d3", "d4", "d5",  "d6",  "d7",
              "a0", "a1", "a2", "a3", "a4", "a5",  "a6",  "a7", "sr", "pc"]:
        if i == "a7":
            initial += x + sp(data['initial'])
        else:
            initial += x + str(data['initial'][i])
        x = ", "
    initial += " },\n"
    x = "  {"
    for i in ["d0", "d1", "d2", "d3", "d4", "d5",  "d6",  "d7",
              "a0", "a1", "a2", "a3", "a4", "a5",  "a6",  "a7", "sr", "pc"]:
        if i == "a7":
            final += x + sp(data['final'])
        else:
            final += x + str(data['final'][i])
        x = ", "
    final += " },\n"
    prefetch += "  { %d, %d },\n" % (data['initial']['prefetch'][0],
                                     data['initial']['prefetch'][1])
    iram += "  { %d" % len(data['initial']['ram'])
    for i in data['initial']['ram']:
        iram += ", %d, %d" % (i[0], i[1])
    iram += " },\n"
    fram += "  { %d" % len(data['final']['ram'])
    for i in data['final']['ram']:
        fram += ", %d, %d" % (i[0], i[1])
    fram += " },\n"

if __name__ == "__main__":
    for i in tests:
        r, w = os.pipe()
        p = subprocess.run(("zcat", "./ProcessorTests/680x0/68000/v1/" + i + ".json.gz"), stdout=subprocess.PIPE)
        for j in json.loads(p.stdout.decode("ascii")):
            check(j)
        f = open("check.c", "w")
        print("#include \"vs100.h\"", file=f)

        print("const char *name[] = {", file=f)
        print(name, file=f)
        print("};", file=f)

        print("u32 initial[][18] = {", file=f)
        print(initial, file=f)
        print("};", file=f)

        print("u32 final[][18] = {", file=f)
        print(final, file=f)
        print("};", file=f)

        print("u16 prefetch[][2] = {", file=f)
        print(prefetch, file=f)
        print("};", file=f)

        print("u32 iram[][100] = {", file=f)
        print(iram, file=f)
        print("};", file=f)

        print("u32 fram[][100] = {", file=f)
        print(fram, file=f)
        print("};", file=f)

        print("int tests = %d;" % (count), file=f)
        f.close()
