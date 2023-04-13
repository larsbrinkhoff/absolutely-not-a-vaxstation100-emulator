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

tests = []
#ABCD SBCD NBCD
tests += ["ADDA.w", "ADDA.l"]
tests += ["ADD.b", "ADD.w", "ADD.l"]
#ADDX
tests += ["AND.b", "AND.w", "AND.l"]
tests += ["ANDItoCCR", "ANDItoSR", "EORItoCCR", "EORItoSR"]
tests += ["MOVEtoCCR", "MOVEtoSR", "ORItoCCR", "ORItoSR"]
#tests += ["ASL.b", "ASL.w", "ASL.l"]   #nok
#tests += ["ASR.b", "ASR.w", "ASR.l"]   #nok
tests += ["Bcc", "BSR"]
tests += ["BCHG", "BCLR", "BSET", "BTST"]
tests += ["CLR.b", "CLR.w", "CLR.l"]
tests += ["CMPA.w", "CMPA.l"]
tests += ["CMPA.w", "CMPA.l"]
tests += ["CMP.b", "CMP.w", "CMP.l"]
tests += ["DBcc", "Scc"]
#tests += ["DIVS", "DIVU"]  #nok
tests += ["EOR.b", "EOR.w", "EOR.l"]
tests += ["OR.b", "OR.w", "OR.l"]
tests += ["EXG", "EXT.w", "EXT.l"]
tests += ["JMP", "JSR"]
tests += ["LEA", "PEA"]
#LSL LSR
tests += ["MOVEA.w", "MOVEA.l"]
tests += ["MOVE.b", "MOVE.w", "MOVE.l"]
tests += ["MOVEM.w", "MOVEM.l"]
tests += ["MOVE.q"]
#tests += ["MULS", "MULU"]  #nok
tests += ["NEG.b", "NEG.w", "NEG.l"]
tests += ["NOP"]
tests += ["NOT.b", "NOT.w", "NOT.l"]
#ROL ROR
tests += ["RTE", "RTS"]  #nok rte
#RTR
tests += ["SUBA.l", "SUBA.w"]
tests += ["SUB.b", "SUB.l", "SUB.w"]  #nok
tests += ["SWAP"]
#TRAP TRAPV
tests += ["TST.b", "TST.w", "TST.l"]
#LINK UNLINK

count = 0

def sp(data):
    if (data['sr'] & 0x2000) == 0:
        return str(data['usp'])
    else:
        return str(data['ssp'])

def check(f, data):
    global count
    count += 1
    print("  { \"%s\"," % data['name'], file=f)
    x = "    { "
    for i in ["d0", "d1", "d2", "d3", "d4", "d5",  "d6",  "d7",
              "a0", "a1", "a2", "a3", "a4", "a5",  "a6",  "a7",
              "usp", "ssp", "sr", "pc"]:
        if i == "a7":
            print(x + sp(data['initial']), file=f, end="")
        else:
            print(x + str(data['initial'][i]), file=f, end="")
        x = ", "
    print(" },", file=f)
    x = "    {"
    for i in ["d0", "d1", "d2", "d3", "d4", "d5",  "d6",  "d7",
              "a0", "a1", "a2", "a3", "a4", "a5",  "a6",  "a7",
              "usp", "ssp", "sr", "pc"]:
        if i == "a7":
            print(x + sp(data['final']), file=f, end="")
        else:
            print(x + str(data['final'][i]), file=f, end="")
        x = ", "
    print(" },",file=f)
    print("    { %d, %d }," % (data['initial']['prefetch'][0],
                               data['initial']['prefetch'][1]), file=f)
    print("    { %d" % len(data['initial']['ram']), file=f, end="")
    for i in data['initial']['ram']:
        print(", %d, %d" % (i[0], i[1]), file=f, end="")
    print(" },", file=f)
    print("    { %d" % len(data['final']['ram']), file=f, end="")
    for i in data['final']['ram']:
        print(", %d, %d" % (i[0], i[1]), file=f, end="")
    print(" },", file=f)
    print("  },", file=f)

def generate(insn):
    global count
    count = 0
    cmd = ("zcat", "./ProcessorTests/680x0/68000/v1/" + insn + ".json.gz")
    p = subprocess.run(cmd, stdout=subprocess.PIPE)
    f = open("check_data.c", "w")
    print("#include \"vs100.h\"\n", file=f)
    print("#include \"check.h\"\n", file=f)
    print("const struct check check_data[] = {", file=f)
    for i in json.loads(p.stdout.decode("ascii")):
        check(f, i)
    print("};", file=f)
    print("int tests = %d;" % (count), file=f)
    f.close()

def test():
    p = subprocess.run("make", stdout=subprocess.DEVNULL)
    p = subprocess.run("./vs100")

if __name__ == "__main__":
    for i in tests:
        print("Test: " + i)
        generate(i)
        test()
