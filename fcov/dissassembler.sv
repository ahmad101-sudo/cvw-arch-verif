`include "riscv_instr.svh"

module dissassembler #(parameter XLEN = 32) (
  input  logic [31:0] instr,
  output string       decoded);

  import riscv_instr::*;

  logic [6:0] op;
  logic       funct1;
  logic [1:0] funct2;
  logic [2:0] funct3;
  logic [4:0] funct5;
  logic [6:0] funct7;
  logic [1:0] fmt;
  logic signed [11:0] immIType;
  logic signed [11:0] immSType;
  logic signed [11:0] immBType;
  logic signed [19:0] immUType;
  logic signed [20:0] immJType;
  logic [5:0] uimm;
  logic [4:0] rs1, rs2, rs3, rd, CRrs2;
  logic [1:0] compressedOp;
  logic [5:0] compressed15_10;

  // Immediate values
  assign immIType = $signed(instr[31:20]);
  assign immSType = $signed({instr[31:25], instr[11:7]});
  assign immBType = $signed({instr[31], instr[7], instr[30:25], instr[11:8]});
  assign immUType = {instr[31:12]};
  assign immJType = $signed({instr[31], instr[19:12], instr[20], instr[30:21], 1'b0});
  assign uimm = instr[25:20];

  // Registers (also used for floating point)
  assign rs1 = instr[19:15];
  assign rs2 = instr[24:20];
  assign rs3 = instr[31:27];
  assign rd = instr[11:7];

  /* verilator lint_off CASEINCOMPLETE */
  always_comb begin
    decoded = "illegal";
    casez (instr)
      // Base Instructions
      ADD:     $sformat(decoded, "add x%0d, x%0d, x%0d", rd, rs1, rs2);
      ADDI:    $sformat(decoded, "addi x%0d, x%0d, %0d", rd, rs1, immIType);
      AND:     $sformat(decoded, "and x%0d, x%0d, x%0d", rd, rs1, rs2);
      ANDI:    $sformat(decoded, "andi x%0d, x%0d, %0d", rd, rs1, immIType);
      AUIPC:   $sformat(decoded, "auipc x%0d, 0x%0h", rd, immUType);
      BEQ:     $sformat(decoded, "beq x%0d, x%0d, %0h", rs1, rs2, immBType);
      BGE:     $sformat(decoded, "bge x%0d, x%0d, %0h", rs1, rs2, immBType);
      BGEU:    $sformat(decoded, "bgeu x%0d, x%0d, %0h", rs1, rs2, immBType);
      BLT:     $sformat(decoded, "blt x%0d, x%0d, %0h", rs1, rs2, immBType);
      BLTU:    $sformat(decoded, "bltu x%0d, x%0d, %0h", rs1, rs2, immBType);
      BNE:     $sformat(decoded, "bne x%0d, x%0d, %0h", rs1, rs2, immBType);
      EBREAK:  $sformat(decoded, "ebreak");
      ECALL:   $sformat(decoded, "ecall");
      FENCE:   $sformat(decoded, "fence");
      JAL:     $sformat(decoded, "jal x%0d, %0h", rd, immJType);
      JALR:    $sformat(decoded, "jalr x%0d, %0d(x%0d)", rd, immIType, rs1);
      LB:      $sformat(decoded, "lb x%0d, %0d(x%0d)", rd, immIType, rs1);
      LBU:     $sformat(decoded, "lbu x%0d, %0d(x%0d)", rd, immIType, rs1);
      LH:      $sformat(decoded, "lh x%0d, %0d(x%0d)", rd, immIType, rs1);
      LHU:     $sformat(decoded, "lhu x%0d, %0d(x%0d)", rd, immIType, rs1);
      LUI:     $sformat(decoded, "lui x%0d, %0d", rd, immUType);
      LW:      $sformat(decoded, "lw x%0d, %0d(x%0d)", rd, immIType, rs1);
      MRET:    $sformat(decoded, "mret");
      OR:      $sformat(decoded, "or x%0d, x%0d, x%0d", rd, rs1, rs2);
      ORI:     $sformat(decoded, "ori x%0d, x%0d, %0d", rd, rs1, immIType);
      SB:      $sformat(decoded, "sb x%0d, %0d(x%0d)", rs2, immSType, rs1);
      SH:      $sformat(decoded, "sh x%0d, %0d(x%0d)", rs2, immSType, rs1);
      SLL:     $sformat(decoded, "sll x%0d, x%0d, x%0d", rd, rs1, rs2);
      SLLI:    $sformat(decoded, "slli x%0d, x%0d, %0d", rd, rs1, uimm); // TODO: shift amount
      SLT:     $sformat(decoded, "slt x%0d, x%0d, x%0d", rd, rs1, rs2);
      SLTI:    $sformat(decoded, "slti x%0d, x%0d, %0d", rd, rs1, immIType);
      SLTIU:   $sformat(decoded, "sltiu x%0d, x%0d, %0d", rd, rs1, immIType);
      SLTU:    $sformat(decoded, "sltu x%0d, x%0d, x%0d", rd, rs1, rs2);
      SRA:     $sformat(decoded, "sra x%0d, x%0d, x%0d", rd, rs1, rs2);
      SRAI:    $sformat(decoded, "srai x%0d, x%0d, %0d", rd, rs1, uimm); // TODO: shift amount
      SRL:     $sformat(decoded, "srl x%0d, x%0d, x%0d", rd, rs1, rs2);
      SRLI:    $sformat(decoded, "srli x%0d, x%0d, %0d", rd, rs1, uimm); // TODO: shift amount
      SUB:     $sformat(decoded, "sub x%0d, x%0d, x%0d", rd, rs1, rs2);
      SW:      $sformat(decoded, "sw x%0d, %0d(x%0d)", rs2, immSType, rs1);
      WFI:     $sformat(decoded, "wfi");
      XOR:     $sformat(decoded, "xor x%0d, x%0d, x%0d", rd, rs1, rs2);
      XORI:    $sformat(decoded, "xori x%0d, x%0d, %0d", rd, rs1, immIType);
      // Extra RV64 Base Instructions
      ADDIW: $sformat(decoded, "addiw x%0d, x%0d, %0d", rd, rs1, immIType);
      ADDW:  $sformat(decoded, "addw x%0d, x%0d, x%0d", rd, rs1, rs2);
      LD:    $sformat(decoded, "ld x%0d, %0d(x%0d)", rd, immIType, rs1);
      LWU:   $sformat(decoded, "lwu x%0d, %0d(x%0d)", rd, immIType, rs1);
      SD:    $sformat(decoded, "sd x%0d, %0d(x%0d)", rs2, immSType, rs1);
      SLLIW: $sformat(decoded, "slliw x%0d, x%0d, %0d", rd, rs1, uimm);
      SLLW:  $sformat(decoded, "sllw x%0d, x%0d, x%0d", rd, rs1, rs2);
      SRAIW: $sformat(decoded, "sraiw x%0d, x%0d, %0d", rd, rs1, uimm);
      SRAW:  $sformat(decoded, "sraw x%0d, x%0d, x%0d", rd, rs1, rs2);
      SRLIW: $sformat(decoded, "srliw x%0d, x%0d, %0d", rd, rs1, uimm);
      SRLW:  $sformat(decoded, "srlw x%0d, x%0d, x%0d", rd, rs1, rs2);
      SUBW:  $sformat(decoded, "subw x%0d, x%0d, x%0d", rd, rs1, rs2);
      // Supervisor Mode Instructions
      SFENCE_VMA: $sformat(decoded, "sfence.vma x%0d, x%0d", rs1, rs2);
      SRET:       $sformat(decoded, "sret");
      // Zicboz Extension
      CBO_ZERO: $sformat(decoded, "cbo.zero (x%0d)", rs1);
      // Zicbom Extension
      CBO_CLEAN: $sformat(decoded, "cbo.clean (x%0d)", rs1);
      CBO_FLUSH: $sformat(decoded, "cbo.flush (x%0d)", rs1);
      CBO_INVAL: $sformat(decoded, "cbo.inval (x%0d)", rs1);
      // Zicbop Extension
      PREFETCH_I: $sformat(decoded, "prefetch.i %0d(x%0d)", immIType, rs1);
      PREFETCH_R: $sformat(decoded, "prefetch.r %0d(x%0d)", immIType, rs1);
      PREFETCH_W: $sformat(decoded, "prefetch.w %0d(x%0d)", immIType, rs1);
      // Zicond Extension
      CZERO_EQZ: $sformat(decoded, "czero.eqz x%0d, x%0d, x%0d", rd, rs1, rs2);
      CZERO_NEZ: $sformat(decoded, "czero.nez x%0d, x%0d, x%0d", rd, rs1, rs2);
      // Zicsr Extension
      CSRRW:  $sformat(decoded, "csrrw x%0d, %0d, x%0d", rd, immIType, rs1);
      CSRRS:  $sformat(decoded, "csrrs x%0d, %0d, x%0d", rd, immIType, rs1);
      CSRRC:  $sformat(decoded, "csrrc x%0d, %0d, x%0d", rd, immIType, rs1);
      CSRRWI: $sformat(decoded, "csrrwi x%0d, %0d, %0d", rd, immIType, rs1);
      CSRRSI: $sformat(decoded, "csrrsi x%0d, %0d, %0d", rd, immIType, rs1);
      CSRRCI: $sformat(decoded, "csrrci x%0d, %0d, %0d", rd, immIType, rs1);
      // Zifencei Extension
      FENCE_I: $sformat(decoded, "fence.i");
      // M Extension
      MUL:  $sformat(decoded, "mul x%0d, x%0d, x%0d", rd, rs1, rs2);
      MULH: $sformat(decoded, "mulh x%0d, x%0d, x%0d", rd, rs1, rs2);
      MULHSU: $sformat(decoded, "mulhsu x%0d, x%0d, x%0d", rd, rs1, rs2);
      MULHU: $sformat(decoded, "mulhu x%0d, x%0d, x%0d", rd, rs1, rs2);
      DIV:  $sformat(decoded, "div x%0d, x%0d, x%0d", rd, rs1, rs2);
      DIVU: $sformat(decoded, "divu x%0d, x%0d, x%0d", rd, rs1, rs2);
      REM:  $sformat(decoded, "rem x%0d, x%0d, x%0d", rd, rs1, rs2);
      REMU: $sformat(decoded, "remu x%0d, x%0d, x%0d", rd, rs1, rs2);
      // RV64 Only M Extension Instructions
      MULW:  $sformat(decoded, "mulw x%0d, x%0d, x%0d", rd, rs1, rs2);
      DIVW:  $sformat(decoded, "divw x%0d, x%0d, x%0d", rd, rs1, rs2);
      DIVUW: $sformat(decoded, "divuw x%0d, x%0d, x%0d", rd, rs1, rs2);
      REMW:  $sformat(decoded, "remw x%0d, x%0d, x%0d", rd, rs1, rs2);
      REMUW: $sformat(decoded, "remuw x%0d, x%0d, x%0d", rd, rs1, rs2);
      // Zaamo Extension
      AMOADD_W:  $sformat(decoded, "amoadd.w x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOAND_W:  $sformat(decoded, "amoand.w x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOMAX_W:  $sformat(decoded, "amomax.w x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOMAXU_W: $sformat(decoded, "amomaxu.w x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOMIN_W:  $sformat(decoded, "amomin.w x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOMINU_W: $sformat(decoded, "amominu.w x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOOR_W:   $sformat(decoded, "amoor.w x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOSWAP_W: $sformat(decoded, "amoswap.w x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOXOR_W:  $sformat(decoded, "amoxor.w x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      // RV64 Only Zaamo Extension Instructions
      AMOADD_D:  $sformat(decoded, "amoadd.d x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOAND_D:  $sformat(decoded, "amoand.d x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOMAX_D:  $sformat(decoded, "amomax.d x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOMAXU_D: $sformat(decoded, "amomaxu.d x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOMIN_D:  $sformat(decoded, "amomin.d x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOMINU_D: $sformat(decoded, "amominu.d x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOOR_D:   $sformat(decoded, "amoor.d x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOSWAP_D: $sformat(decoded, "amoswap.d x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      AMOXOR_D:  $sformat(decoded, "amoxor.d x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      // Zalrsc Extension
      LR_W:      $sformat(decoded, "lr.w x%0d, (x%0d)", rd, rs1);
      SC_W:      $sformat(decoded, "sc.w x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      // RV64 Only Zalrsc Extension Instructions
      LR_D:      $sformat(decoded, "lr.d x%0d, (x%0d)", rd, rs1);
      SC_D:      $sformat(decoded, "sc.d x%0d, x%0d, (x%0d)", rd, rs2, rs1);
      // F Extension
      FADD_S:    $sformat(decoded, "fadd.s f%0d, f%0d, f%0d", rd, rs1, rs2);
      FCLASS_S:  $sformat(decoded, "fclass.s x%0d, f%0d", rd, rs1);
      FCVT_S_W:  $sformat(decoded, "fcvt.s.w f%0d, x%0d", rd, rs1);
      FCVT_S_WU: $sformat(decoded, "fcvt.s.wu f%0d, x%0d", rd, rs1);
      FCVT_W_S:  $sformat(decoded, "fcvt.w.s x%0d, f%0d", rd, rs1);
      FCVT_WU_S: $sformat(decoded, "fcvt.wu.s x%0d, f%0d", rd, rs1);
      FDIV_S:    $sformat(decoded, "fdiv.s f%0d, f%0d, f%0d", rd, rs1, rs2);
      FEQ_S:     $sformat(decoded, "feq.s x%0d, f%0d, f%0d", rd, rs1, rs2);
      FLE_S:     $sformat(decoded, "fle.s x%0d, f%0d, f%0d", rd, rs1, rs2);
      FLT_S:     $sformat(decoded, "flt.s x%0d, f%0d, f%0d", rd, rs1, rs2);
      FLW:       $sformat(decoded, "flw f%0d, %0d(x%0d)", rd, immIType, rs1);
      FMADD_S:   $sformat(decoded, "fmadd.s f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FMAX_S:    $sformat(decoded, "fmax.s f%0d, f%0d, f%0d", rd, rs1, rs2);
      FMIN_S:    $sformat(decoded, "fmin.s f%0d, f%0d, f%0d", rd, rs1, rs2);
      FMSUB_S:   $sformat(decoded, "fmsub.s f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FMUL_S:    $sformat(decoded, "fmul.s f%0d, f%0d, f%0d", rd, rs1, rs2);
      FMV_W_X:   $sformat(decoded, "fmv.w.x f%0d, x%0d", rd, rs1);
      FMV_X_W:   $sformat(decoded, "fmv.x.w x%0d, f%0d", rd, rs1);
      FNMADD_S:  $sformat(decoded, "fnmadd.s f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FNMSUB_S:  $sformat(decoded, "fnmsub.s f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      // FRCSR:     $sformat(decoded, "");
      // FRFLAGS:   $sformat(decoded, "");
      // FRRM:      $sformat(decoded, "");
      // FSCSR:     $sformat(decoded, "");
      // FSFLAGS:   $sformat(decoded, "");
      // FSFLAGSI:  $sformat(decoded, "");
      FSGNJ_S:   $sformat(decoded, "fsgnj.s f%0d, f%0d, f%0d", rd, rs1, rs2);
      FSGNJN_S:  $sformat(decoded, "fsgnjn.s f%0d, f%0d, f%0d", rd, rs1, rs2);
      FSGNJX_S:  $sformat(decoded, "fsgnjx.s f%0d, f%0d, f%0d", rd, rs1, rs2);
      FSQRT_S:   $sformat(decoded, "fsqrt.s f%0d, f%0d", rd, rs1);
      // FSRM:      $sformat(decoded, "");
      // FSRMI:     $sformat(decoded, ""); TODO: What is this??
      FSUB_S:    $sformat(decoded, "fsub.s f%0d, f%0d, f%0d", rd, rs1, rs2);
      FSW:       $sformat(decoded, "fsw f%0d, %0d(x%0d)", rs2, immSType, rs1);
      // RV64 Only F Extension Instructions
      FCVT_L_S:  $sformat(decoded, "fcvt.l.s x%0d, f%0d", rd, rs1);
      FCVT_LU_S: $sformat(decoded, "fcvt.lu.s x%0d, f%0d", rd, rs1);
      FCVT_S_L:  $sformat(decoded, "fcvt.s.l f%0d, x%0d", rd, rs1);
      FCVT_S_LU: $sformat(decoded, "fcvt.s.lu f%0d, x%0d", rd, rs1);
      // D Extension
      FADD_D:    $sformat(decoded, "fadd.d f%0d, f%0d, f%0d", rd, rs1, rs2);
      FCLASS_D:  $sformat(decoded, "fclass.d x%0d, f%0d", rd, rs1);
      FCVT_D_S:  $sformat(decoded, "fcvt.d.s f%0d, f%0d", rd, rs1);
      FCVT_D_W:  $sformat(decoded, "fcvt.d.w f%0d, x%0d", rd, rs1);
      FCVT_D_WU: $sformat(decoded, "fcvt.d.wu f%0d, x%0d", rd, rs1);
      FCVT_S_D:  $sformat(decoded, "fcvt.s.d f%0d, f%0d", rd, rs1);
      FCVT_W_D:  $sformat(decoded, "fcvt.w.d x%0d, f%0d", rd, rs1);
      FCVT_WU_D: $sformat(decoded, "fcvt.wu.d x%0d, f%0d", rd, rs1);
      FDIV_D:    $sformat(decoded, "fdiv.d f%0d, f%0d, f%0d", rd, rs1, rs2);
      FEQ_D:     $sformat(decoded, "feq.d x%0d, f%0d, f%0d", rd, rs1, rs2);
      FLD:       $sformat(decoded, "fld f%0d, %0d(x%0d)", rd, immIType, rs1);
      FLE_D:     $sformat(decoded, "fle.d x%0d, f%0d, f%0d", rd, rs1, rs2);
      FLT_D:     $sformat(decoded, "flt.d x%0d, f%0d, f%0d", rd, rs1, rs2);
      FMADD_D:   $sformat(decoded, "fmadd.d f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FMAX_D:    $sformat(decoded, "fmax.d f%0d, f%0d, f%0d", rd, rs1, rs2);
      FMIN_D:    $sformat(decoded, "fmin.d f%0d, f%0d, f%0d", rd, rs1, rs2);
      FMSUB_D:   $sformat(decoded, "fmsub.d f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FMUL_D:    $sformat(decoded, "fmul.d f%0d, f%0d, f%0d", rd, rs1, rs2);
      FNMADD_D:  $sformat(decoded, "fnmadd.d f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FNMSUB_D:  $sformat(decoded, "fnmsub.d f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FSD:       $sformat(decoded, "fsd f%0d, %0d(x%0d)", rs2, immSType, rs1);
      FSGNJ_D:   $sformat(decoded, "fsgnj.d f%0d, f%0d, f%0d", rd, rs1, rs2);
      FSGNJN_D:  $sformat(decoded, "fsgnjn.d f%0d, f%0d, f%0d", rd, rs1, rs2);
      FSGNJX_D:  $sformat(decoded, "fsgnjx.d f%0d, f%0d, f%0d", rd, rs1, rs2);
      FSQRT_D:   $sformat(decoded, "fsqrt.d f%0d, f%0d", rd, rs1);
      FSUB_D:    $sformat(decoded, "fsub.d f%0d, f%0d, f%0d", rd, rs1, rs2);
      // RV64 Only D Extension Instructions
      FCVT_D_L:  $sformat(decoded, "fcvt.d.l f%0d, x%0d", rd, rs1);
      FCVT_D_LU: $sformat(decoded, "fcvt.d.lu f%0d, x%0d", rd, rs1);
      FCVT_L_D:  $sformat(decoded, "fcvt.l.d x%0d, f%0d", rd, rs1);
      FCVT_LU_D: $sformat(decoded, "fcvt.lu.d x%0d, f%0d", rd, rs1);
      FMV_D_X:   $sformat(decoded, "fmv.d.x f%0d, x%0d", rd, rs1);
      FMV_X_D:   $sformat(decoded, "fmv.x.d x%0d, f%0d", rd, rs1);
      // Q Extension
      FADD_Q:    $sformat(decoded, "fadd.q f%0d, f%0d, f%0d", rd, rs1, rs2);
      FCLASS_Q:  $sformat(decoded, "fclass.q x%0d, f%0d", rd, rs1);
      FCVT_D_Q:  $sformat(decoded, "fcvt.d.q f%0d, f%0d", rd, rs1);
      FCVT_Q_D:  $sformat(decoded, "fcvt.q.d f%0d, f%0d", rd, rs1);
      FCVT_Q_S:  $sformat(decoded, "fcvt.q.s f%0d, f%0d", rd, rs1);
      FCVT_Q_W:  $sformat(decoded, "fcvt.q.w f%0d, x%0d", rd, rs1);
      FCVT_Q_WU: $sformat(decoded, "fcvt.q.wu f%0d, x%0d", rd, rs1);
      FCVT_S_Q:  $sformat(decoded, "fcvt.s.q f%0d, f%0d", rd, rs1);
      FCVT_W_Q:  $sformat(decoded, "fcvt.w.q x%0d, f%0d", rd, rs1);
      FCVT_WU_Q: $sformat(decoded, "fcvt.wu.q x%0d, f%0d", rd, rs1);
      FDIV_Q:    $sformat(decoded, "fdiv.q f%0d, f%0d, f%0d", rd, rs1, rs2);
      FEQ_Q:     $sformat(decoded, "feq.q x%0d, f%0d, f%0d", rd, rs1, rs2);
      FLE_Q:     $sformat(decoded, "fle.q x%0d, f%0d, f%0d", rd, rs1, rs2);
      FLQ:       $sformat(decoded, "flq f%0d, %0d(x%0d)", rd, immIType, rs1);
      FLT_Q:     $sformat(decoded, "flt.q x%0d, f%0d, f%0d", rd, rs1, rs2);
      FMADD_Q:   $sformat(decoded, "fmadd.q f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FMAX_Q:    $sformat(decoded, "fmax.q f%0d, f%0d, f%0d", rd, rs1, rs2);
      FMIN_Q:    $sformat(decoded, "fmin.q f%0d, f%0d, f%0d", rd, rs1, rs2);
      FMSUB_Q:   $sformat(decoded, "fmsub.q f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FMUL_Q:    $sformat(decoded, "fmul.q f%0d, f%0d, f%0d", rd, rs1, rs2);
      FNMADD_Q:  $sformat(decoded, "fnmadd.q f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FNMSUB_Q:  $sformat(decoded, "fnmsub.q f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FSGNJ_Q:   $sformat(decoded, "fsgnj.q f%0d, f%0d, f%0d", rd, rs1, rs2);
      FSGNJN_Q:  $sformat(decoded, "fsgnjn.q f%0d, f%0d, f%0d", rd, rs1, rs2);
      FSGNJX_Q:  $sformat(decoded, "fsgnjx.q f%0d, f%0d, f%0d", rd, rs1, rs2);
      FSQ:       $sformat(decoded, "fsq f%0d, %0d(x%0d)", rs2, immSType, rs1);
      FSQRT_Q:   $sformat(decoded, "fsqrt.q f%0d, f%0d", rd, rs1);
      FSUB_Q:    $sformat(decoded, "fsub.q f%0d, f%0d, f%0d", rd, rs1, rs2);
      // RV64 Only Q Extension Instructions
      FCVT_L_Q:  $sformat(decoded, "fcvt.l.q x%0d, f%0d", rd, rs1);
      FCVT_LU_Q: $sformat(decoded, "fcvt.lu.q x%0d, f%0d", rd, rs1);
      FCVT_Q_L:  $sformat(decoded, "fcvt.q.l f%0d, x%0d", rd, rs1);
      FCVT_Q_LU: $sformat(decoded, "fcvt.q.lu f%0d, x%0d", rd, rs1);
      // Zfh Extension
      FADD_H:    $sformat(decoded,"fadd.h f%0d, f%0d, f%0d", rd, rs1, rs2);
      FCLASS_H:  $sformat(decoded,"fclass.h x%0d, f%0d", rd, rs1);
      FCVT_H_S:  $sformat(decoded,"fcvt.h.s f%0d, f%0d", rd, rs1);
      FCVT_H_W:  $sformat(decoded,"fcvt.h.w f%0d, x%0d", rd, rs1);
      FCVT_H_WU: $sformat(decoded,"fcvt.h.wu f%0d, x%0d", rd, rs1);
      FCVT_S_H:  $sformat(decoded,"fcvt.s.h f%0d, f%0d", rd, rs1);
      FCVT_W_H:  $sformat(decoded,"fcvt.w.h x%0d, f%0d", rd, rs1);
      FCVT_WU_H: $sformat(decoded,"fcvt.wu.h x%0d, f%0d", rd, rs1);
      FDIV_H:    $sformat(decoded,"fdiv.h f%0d, f%0d, f%0d", rd, rs1, rs2);
      FEQ_H:     $sformat(decoded,"feq.h x%0d, f%0d, f%0d", rd, rs1, rs2);
      FLE_H:     $sformat(decoded,"fle.h x%0d, f%0d, f%0d", rd, rs1, rs2);
      FLH:       $sformat(decoded,"flh f%0d, %0d(x%0d)", rd, immIType, rs1);
      FLT_H:     $sformat(decoded,"flt.h x%0d, f%0d, f%0d", rd, rs1, rs2);
      FMADD_H:   $sformat(decoded,"fmadd.h f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FMAX_H:    $sformat(decoded,"fmax.h f%0d, f%0d, f%0d", rd, rs1, rs2);
      FMIN_H:    $sformat(decoded,"fmin.h f%0d, f%0d, f%0d", rd, rs1, rs2);
      FMSUB_H:   $sformat(decoded,"fmsub.h f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FMUL_H:    $sformat(decoded,"fmul.h f%0d, f%0d, f%0d", rd, rs1, rs2);
      FMV_H_X:   $sformat(decoded,"fmv.h.x f%0d, x%0d", rd, rs1);
      FMV_X_H:   $sformat(decoded,"fmv.x.h x%0d, f%0d", rd, rs1);
      FNMADD_H:  $sformat(decoded,"fnmadd.h f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FNMSUB_H:  $sformat(decoded,"fnmsub.h f%0d, f%0d, f%0d, f%0d", rd, rs1, rs2, rs3);
      FSGNJ_H:   $sformat(decoded,"fsgnj.h f%0d, f%0d, f%0d", rd, rs1, rs2);
      FSGNJN_H:  $sformat(decoded,"fsgnjn.h f%0d, f%0d, f%0d", rd, rs1, rs2);
      FSGNJX_H:  $sformat(decoded,"fsgnjx.h f%0d, f%0d, f%0d", rd, rs1, rs2);
      FSH:       $sformat(decoded,"fsh f%0d, %0d(x%0d)", rs2, immSType, rs1);
      FSQRT_H:   $sformat(decoded,"fsqrt.h f%0d, f%0d", rd, rs1);
      FSUB_H:    $sformat(decoded,"fsub.h f%0d, f%0d, f%0d", rd, rs1, rs2);
      // RV64 Only Zfh Extension Instructions
      FCVT_H_L:  $sformat(decoded,"fcvt.h.l f%0d, x%0d", rd, rs1);
      FCVT_H_LU: $sformat(decoded,"fcvt.h.lu f%0d, x%0d", rd, rs1);
      FCVT_L_H:  $sformat(decoded,"fcvt.l.h x%0d, f%0d", rd, rs1);
      FCVT_LU_H: $sformat(decoded,"fcvt.lu.h x%0d, f%0d", rd, rs1);
      // Zfh + D Extensions
      FCVT_D_H: $sformat(decoded,"fcvt.d.h f%0d, f%0d", rd, rs1);
      FCVT_H_D: $sformat(decoded,"fcvt.h.d f%0d, f%0d", rd, rs1);
      // Zfh + Q Extensions
      FCVT_H_Q: $sformat(decoded,"fcvt.h.q f%0d, f%0d", rd, rs1);
      FCVT_Q_H: $sformat(decoded,"fcvt.q.h f%0d, f%0d", rd, rs1);
      // Zfa Extension
      FLEQ_S:     $sformat(decoded, "fleq.s x%0d, f%0d, f%0d", rd, rs1, rs2);
      FLI_S:      $sformat(decoded, "fli.s f%0d, x%0d", rd, rs1);
      FLTQ_S:     $sformat(decoded, "fltq.s x%0d, f%0d, f%0d", rd, rs1, rs2);
      FMAXM_S:    $sformat(decoded, "fmaxm.s f%0d, f%0d, f%0d", rd, rs1, rs2);
      FMINM_S:    $sformat(decoded, "fminm.s f%0d, f%0d, f%0d", rd, rs1, rs2);
      FROUND_S:   $sformat(decoded, "fround.s f%0d, f%0d", rd, rs1);
      FROUNDNX_S: $sformat(decoded, "froundnx.s f%0d, f%0d", rd, rs1);
      // Zfa + D Extensions
      FCVTMOD_W_D: $sformat(decoded, "fcvtmod.w.d x%0d, f%0d", rd, rs1);
      FLEQ_D:      $sformat(decoded, "fleq.d x%0d, f%0d, f%0d", rd, rs1, rs2);
      FLI_D:       $sformat(decoded, "fli.d f%0d, x%0d", rd, rs1);
      FLTQ_D:      $sformat(decoded, "fltq.d x%0d, f%0d, f%0d", rd, rs1, rs2);
      FMAXM_D:     $sformat(decoded, "fmaxm.d f%0d, f%0d, f%0d", rd, rs1, rs2);
      FMINM_D:     $sformat(decoded, "fminm.d f%0d, f%0d, f%0d", rd, rs1, rs2);
      FROUND_D:    $sformat(decoded, "fround.d f%0d, f%0d", rd, rs1);
      FROUNDNX_D:  $sformat(decoded, "froundnx.d f%0d, f%0d", rd, rs1);
      // RV32 Only Zfa + D Extensions
      FMVP_D_X: $sformat(decoded, "fmvp.d.x f%0d, x%0d, x%0d", rd, rs1, rs2);
      FMVH_X_D: $sformat(decoded, "fmvh.x.d x%0d, f%0d", rd, rs1);
      // Zfa + Q Extensions
      FLEQ_Q:     $sformat(decoded, "fleq.q x%0d, f%0d, f%0d", rd, rs1, rs2);
      FLI_Q:      $sformat(decoded, "fli.q f%0d, x%0d", rd, rs1);
      FLTQ_Q:     $sformat(decoded, "fltq.q x%0d, f%0d, f%0d", rd, rs1, rs2);
      FMAXM_Q:    $sformat(decoded, "fmaxm.q f%0d, f%0d, f%0d", rd, rs1, rs2);
      FMINM_Q:    $sformat(decoded, "fminm.q f%0d, f%0d, f%0d", rd, rs1, rs2);
      FROUND_Q:   $sformat(decoded, "fround.q f%0d, f%0d", rd, rs1);
      FROUNDNX_Q: $sformat(decoded, "froundnx.q f%0d, f%0d", rd, rs1);
      // RV64 Only Zfa + Q Extensions
      FMVP_Q_X: $sformat(decoded, "fmvp.q.x f%0d, x%0d, x%0d", rd, rs1, rs2);
      FMVH_X_Q: $sformat(decoded, "fmvh.x.q x%0d, f%0d", rd, rs1);
      // Zfh + Zfa Extensions
      FLEQ_H:     $sformat(decoded, "fleq.h x%0d, f%0d, f%0d", rd, rs1, rs2);
      FLI_H:      $sformat(decoded, "fli.h f%0d, x%0d", rd, rs1);
      FLTQ_H:     $sformat(decoded, "fltq.h x%0d, f%0d, f%0d", rd, rs1, rs2);
      FMAXM_H:    $sformat(decoded, "fmaxm.h f%0d, f%0d, f%0d", rd, rs1, rs2);
      FMINM_H:    $sformat(decoded, "fminm.h f%0d, f%0d, f%0d", rd, rs1, rs2);
      FROUND_H:   $sformat(decoded, "fround.h f%0d, f%0d", rd, rs1);
      FROUNDNX_H: $sformat(decoded, "froundnx.h f%0d, f%0d", rd, rs1);
      // Zba Extension
      SH1ADD: $sformat(decoded, "sh1add x%0d, x%0d, x%0d", rd, rs1, rs2);
      SH2ADD: $sformat(decoded, "sh2add x%0d, x%0d, x%0d", rd, rs1, rs2);
      SH3ADD: $sformat(decoded, "sh3add x%0d, x%0d, x%0d", rd, rs1, rs2);
      // RV64 Only Zba Extension Instructions
      ADD_UW:    $sformat(decoded, "add.uw x%0d, x%0d, x%0d", rd, rs1, rs2);
      SH1ADD_UW: $sformat(decoded, "sh1add.uw x%0d, x%0d, x%0d", rd, rs1, rs2);
      SH2ADD_UW: $sformat(decoded, "sh2add.uw x%0d, x%0d, x%0d", rd, rs1, rs2);
      SH3ADD_UW: $sformat(decoded, "sh3add.uw x%0d, x%0d, x%0d", rd, rs1, rs2);
      SLLI_UW:   $sformat(decoded, "slli.uw x%0d, x%0d, %0d", rd, rs1, uimm);
      // Zbb Extension
      ANDN:   $sformat(decoded, "andn x%0d, x%0d, x%0d", rd, rs1, rs2);
      CLZ:    $sformat(decoded, "clz x%0d, x%0d", rd, rs1);
      CPOP:   $sformat(decoded, "cpop x%0d, x%0d", rd, rs1);
      CTZ:    $sformat(decoded, "ctz x%0d, x%0d", rd, rs1);
      MAX:    $sformat(decoded, "max x%0d, x%0d, x%0d", rd, rs1, rs2);
      MAXU:   $sformat(decoded, "maxu x%0d, x%0d, x%0d", rd, rs1, rs2);
      MIN:    $sformat(decoded, "min x%0d, x%0d, x%0d", rd, rs1, rs2);
      MINU:   $sformat(decoded, "minu x%0d, x%0d, x%0d", rd, rs1, rs2);
      ORC_B:  $sformat(decoded, "orc.b x%0d, x%0d", rd, rs1);
      ORN:    $sformat(decoded, "orn x%0d, x%0d, x%0d", rd, rs1, rs2);
      REV8:   $sformat(decoded, "rev8 x%0d, x%0d", rd, rs1);
      ROL:    $sformat(decoded, "rol x%0d, x%0d, x%0d", rd, rs1, rs2);
      ROR:    $sformat(decoded, "ror x%0d, x%0d, x%0d", rd, rs1, rs2);
      RORI:   $sformat(decoded, "rori x%0d, x%0d, %0d", rd, rs1, uimm);
      SEXT_B: $sformat(decoded, "sext.b x%0d, x%0d", rd, rs1);
      SEXT_H: $sformat(decoded, "sext.h x%0d, x%0d", rd, rs1);
      XNOR:   $sformat(decoded, "xnor x%0d, x%0d, x%0d", rd, rs1, rs2);
      ZEXT_H: $sformat(decoded, "zext.h x%0d, x%0d", rd, rs1);
      // RV64 Only Zbb Extension Instructions
      CLZW:   $sformat(decoded, "clzw x%0d, x%0d", rd, rs1);
      CPOPW:  $sformat(decoded, "cpopw x%0d, x%0d", rd, rs1);
      CTZW:   $sformat(decoded, "ctzw x%0d, x%0d", rd, rs1);
      ROLW:   $sformat(decoded, "rolw x%0d, x%0d, x%0d", rd, rs1, rs2);
      RORIW:  $sformat(decoded, "roriw x%0d, x%0d, %0d", rd, rs1, uimm);
      RORW:   $sformat(decoded, "rorw x%0d, x%0d, x%0d", rd, rs1, rs2);
      // Zbc Extension
      CLMUL:  $sformat(decoded, "clmul x%0d, x%0d, x%0d", rd, rs1, rs2);
      CLMULH: $sformat(decoded, "clmulh x%0d, x%0d, x%0d", rd, rs1, rs2);
      CLMULR: $sformat(decoded, "clmulr x%0d, x%0d, x%0d", rd, rs1, rs2);
      // Zbs Extension
      BCLR:  $sformat(decoded, "bclr x%0d, x%0d x%0d", rd, rs1, rs2);
      BCLRI: $sformat(decoded, "bclri x%0d, x%0d, %0d", rd, rs1, uimm);
      BEXT:  $sformat(decoded, "bext x%0d, x%0d x%0d", rd, rs1, rs2);
      BEXTI: $sformat(decoded, "bexti x%0d, x%0d, %0d", rd, rs1, uimm);
      BINV:  $sformat(decoded, "binv x%0d, x%0d x%0d", rd, rs1, rs2);
      BINVI: $sformat(decoded, "binvi x%0d, x%0d, %0d", rd, rs1, uimm);
      BSET:  $sformat(decoded, "bset x%0d, x%0d x%0d", rd, rs1, rs2);
      BSETI: $sformat(decoded, "bseti x%0d, x%0d, %0d", rd, rs1, uimm);
      // Zbkb Extension
      BREV8: $sformat(decoded, "brv8 x%0d, x%0d", rd, rs1);
      PACK:  $sformat(decoded, "pack x%0d, x%0d, x%0d", rd, rs1, rs2);
      PACKH: $sformat(decoded, "packh x%0d, x%0d, x%0d", rd, rs1, rs2);
      // RV64 Only Zbkb Extension Instructions
      PACKW: $sformat(decoded, "packw x%0d, x%0d, x%0d", rd, rs1, rs2);
      // RV32 Only Zbkb Extension Instructions
      UNZIP: $sformat(decoded, "unzip x%0d, x%0d", rd, rs1);
      ZIP:   $sformat(decoded, "zip x%0d, x%0d", rd, rs1);
      // Zbkx Extension
      XPERM4: $sformat(decoded, "xperm4 x%0d, x%0d, x%0d", rd, rs1, rs2);
      XPERM8: $sformat(decoded, "xperm8 x%0d, x%0d, x%0d", rd, rs1, rs2);
      // Zknd Extension
      default: decoded = "illegal";
    endcase
  end
endmodule
