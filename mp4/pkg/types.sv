package pcmux;
typedef enum bit [1:0] {
    pc_plus4 = 2'b00,
    alu_out  = 2'b01,
    alu_mod2 = 2'b10
} pcmux_sel_t;
endpackage

package marmux;
typedef enum bit {
    pc_out   = 1'b0,
    alu_out  = 1'b1
} marmux_sel_t;
endpackage

package cmpmux;
typedef enum bit {
    rs2_out  = 1'b0,
    i_imm    = 1'b1
} cmpmux_sel_t;
endpackage

package alumux;
typedef enum bit {
    rs1_out  = 1'b0,
    pc_out   = 1'b1
} alumux1_sel_t;

typedef enum bit [2:0] {
    i_imm    = 3'b000,
    s_imm    = 3'b011,
    b_imm    = 3'b010,
    u_imm    = 3'b001,
    j_imm    = 3'b100,
    rs2_out  = 3'b101
} alumux2_sel_t;
endpackage

package regfilemux;
typedef enum bit [3:0] {
    alu_out  = 4'b0000,
    br_en    = 4'b0001,
    u_imm    = 4'b0010,
    pc_plus4 = 4'b0100,
    lw       = 4'b0011,
    lb       = 4'b0101,
    lbu      = 4'b0110, // unsigned byte
    lh       = 4'b0111,
    lhu      = 4'b1000  // unsigned halfword
} regfilemux_sel_t;
endpackage



package rv32i_types;

import pcmux::*;
import marmux::*;
import cmpmux::*;
import alumux::*;
import regfilemux::*;

typedef logic [31:0] rv32i_word;
typedef logic [ 4:0] rv32i_reg;
typedef logic [ 3:0] rv32i_mem_wmask;

typedef enum bit [6:0] {
    op_lui   = 7'b0110111,  // load upper immediate (U type)
    op_auipc = 7'b0010111,  // add upper immediate PC (U type)
    op_jal   = 7'b1101111,  // jump and link (J type)
    op_jalr  = 7'b1100111,  // jump and link register (I type)
    op_br    = 7'b1100011,  // branch (B type)
    op_imm   = 7'b0010011,  // arith ops with register/immediate operands (I type)
    op_reg   = 7'b0110011,  // arith ops with register operands (R type)
    op_load  = 7'b0000011,  // load (I type)
    op_store = 7'b0100011,  // store (S type)
    op_csr   = 7'b1110011   // control and status register (I type)
} rv32i_opcode;

typedef enum bit [2:0] {
    add  = 3'b000, //check bit30 for sub if op_reg opcode
    sll  = 3'b001,
    slt  = 3'b010,
    sltu = 3'b011,
    axor = 3'b100,
    sr   = 3'b101, //check bit30 for logical/arithmetic
    aor  = 3'b110,
    aand = 3'b111
} arith_funct3_t;

typedef enum bit [2:0] {
    alu_add = 3'b000,
    alu_sll = 3'b001,
    alu_sra = 3'b010,
    alu_sub = 3'b011,
    alu_xor = 3'b100,
    alu_srl = 3'b101,
    alu_or  = 3'b110,
    alu_and = 3'b111
} alu_ops;

typedef enum bit [2:0] {
    beq  = 3'b000,
    bne  = 3'b001,
    blt  = 3'b100,
    bge  = 3'b101,
    bltu = 3'b110,
    bgeu = 3'b111
} branch_funct3_t;

typedef branch_funct3_t cmp_ops;

typedef enum bit [2:0] {
    lb  = 3'b000,
    lh  = 3'b001,
    lw  = 3'b010,
    lbu = 3'b100,
    lhu = 3'b101
} load_funct3_t;

typedef enum bit [2:0] {
    sb = 3'b000,
    sh = 3'b001,
    sw = 3'b010
} store_funct3_t;

endpackage : rv32i_types



package pipeline_pkg;
import rv32i_types::*;

typedef struct packed {
    rv32i_word pc;
    rv32i_word ir;
    rv32i_word r1;
    rv32i_word r2;
    rv32i_word mdr;
    rv32i_word uim;
    rv32i_word alu;
    logic cmp;
    pcmux::pcmux_sel_t pcmux_sel; // haor2 : added for branch. PCmux input can't be from EX stage in that it can change over a cycle. 
    // for monitor compatibility
    rv32i_word _pc_wdata;
    rv32i_word _mem_addr;
    rv32i_word _mem_wdata;
    logic [3:0] _mem_rmask;
    logic [3:0] _mem_wmask;
} pipeline_reg_t;

typedef struct packed {
    alu_ops aluop;
    cmp_ops cmpop;
    alumux::alumux1_sel_t alumux1_sel;
    alumux::alumux2_sel_t alumux2_sel;
    cmpmux::cmpmux_sel_t cmpmux_sel;
    pcmux::pcmux_sel_t pcmux_sel;
    logic is_branch;
} ctrlex_reg_t;

typedef struct packed {
    marmux::marmux_sel_t marmux_sel;
    rv32i_opcode opcode;
    logic [2:0] funct3;
    logic dmem_read;
    logic dmem_write;
} ctrlmem_reg_t;

typedef struct packed {
    regfilemux::regfilemux_sel_t regfilemux_sel;
    logic load_regfile;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
} ctrlwb_reg_t;

endpackage : pipeline_pkg



package hazard_ctrl_pkg;
import rv32i_types::*;
typedef struct packed {
    logic load_pc;
    logic load_if_id;
    logic load_id_ex;
    logic load_ex_mem;
    logic load_mem_wb;
} hazard_ctrl_t;

endpackage : hazard_ctrl_pkg
