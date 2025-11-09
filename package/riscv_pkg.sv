package riscv_pkg;

  typedef enum logic [1:0] {
    PRIV_LVL_M = 2'b11,
    PRIV_LVL_S = 2'b01,
    PRIV_LVL_U = 2'b00
  } priv_lvl_t;

  typedef enum logic [1:0] {
    XLEN_32  = 2'b01,
    XLEN_64  = 2'b10,
    XLEN_128 = 2'b11
  } xlen_t;

  typedef enum logic [1:0] {
    Off     = 2'b00,
    Initial = 2'b01,
    Clean   = 2'b10,
    Dirty   = 2'b11
  } xs_t;

  typedef struct packed {
    logic         sd;
    logic [62:36] wpri4;
    xlen_t        sxl;
    xlen_t        uxl;
    logic [8:0]   wpri3;
    logic         tsr;
    logic         tw;
    logic         tvm;
    logic         mxr;
    logic         sum;
    logic         mprv;
    xs_t          xs;
    xs_t          fs;
    priv_lvl_t    mpp;
    logic [1:0]   wpri2;
    logic         spp;
    logic         mpie;
    logic         wpri1;
    logic         spie;
    logic         upie;
    logic         mie;
    logic         wpri0;
    logic         sie;
    logic         uie;
  } status_rv64_t;

  typedef struct packed {
    logic       sd;
    logic [7:0] wpri3;
    logic       tsr;
    logic       tw;
    logic       tvm;
    logic       mxr;
    logic       sum;
    logic       mprv;
    logic [1:0] xs;
    logic [1:0] fs;
    priv_lvl_t  mpp;
    logic [1:0] wpri2;
    logic       spp;
    logic       mpie;
    logic       wpri1;
    logic       spie;
    logic       upie;
    logic       mie;
    logic       wpri0;
    logic       sie;
    logic       uie;
  } status_rv32_t;

  typedef struct packed {
    logic [3:0]  mode;
    logic [15:0] asid;
    logic [43:0] ppn;
  } satp_t;

  typedef struct packed {
    logic [31:25] funct7;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:12] funct3;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } rtype_t;

  typedef struct packed {
    logic [31:27] rs3;
    logic [26:25] funct2;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:12] funct3;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } r4type_t;

  typedef struct packed {
    logic [31:27] funct5;
    logic [26:25] fmt;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:12] rm;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } rftype_t;

  typedef struct packed {
    logic [31:30] funct2;
    logic [29:25] vecfltop;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:14] repl;
    logic [13:12] vfmt;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } rvftype_t;

  typedef struct packed {
    logic [31:20] imm;
    logic [19:15] rs1;
    logic [14:12] funct3;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } itype_t;

  typedef struct packed {
    logic [31:25] imm;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:12] funct3;
    logic [11:7]  imm0;
    logic [6:0]   opcode;
  } stype_t;

  typedef struct packed {
    logic [31:12] funct3;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } utype_t;

  typedef struct packed {
    logic [31:27] funct5;
    logic         aq;
    logic         rl;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:12] funct3;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } atype_t;

  typedef union packed {
    logic [31:0] instr;
    rtype_t      rtype;
    r4type_t     r4type;
    rftype_t     rftype;
    rvftype_t    rvftype;
    itype_t      itype;
    stype_t      stype;
    utype_t      utype;
    atype_t      atype;
  } instruction_t;

  localparam OpcodeLoad = 7'b00_000_11;
  localparam OpcodeLoadFp = 7'b00_001_11;
  localparam OpcodeCustom0 = 7'b00_010_11;
  localparam OpcodeMiscMem = 7'b00_011_11;
  localparam OpcodeOpImm = 7'b00_100_11;
  localparam OpcodeAuipc = 7'b00_101_11;
  localparam OpcodeOpImm32 = 7'b00_110_11;

  localparam OpcodeStore = 7'b01_000_11;
  localparam OpcodeStoreFp = 7'b01_001_11;
  localparam OpcodeCustom1 = 7'b01_010_11;
  localparam OpcodeAmo = 7'b01_011_11;
  localparam OpcodeOp = 7'b01_100_11;
  localparam OpcodeLui = 7'b01_101_11;
  localparam OpcodeOp32 = 7'b01_110_11;

  localparam OpcodeMadd = 7'b10_000_11;
  localparam OpcodeMsub = 7'b10_001_11;
  localparam OpcodeNmsub = 7'b10_010_11;
  localparam OpcodeNmadd = 7'b10_011_11;
  localparam OpcodeOpFp = 7'b10_100_11;
  localparam OpcodeRsrvd1 = 7'b10_101_11;
  localparam OpcodeCustom2 = 7'b10_110_11;

  localparam OpcodeBranch = 7'b11_000_11;
  localparam OpcodeJalr = 7'b11_001_11;
  localparam OpcodeRsrvd2 = 7'b11_010_11;
  localparam OpcodeJal = 7'b11_011_11;
  localparam OpcodeSystem = 7'b11_100_11;
  localparam OpcodeRsrvd3 = 7'b11_101_11;
  localparam OpcodeCustom3 = 7'b11_110_11;

  localparam OpcodeC0 = 2'b00;
  localparam OpcodeC0Addi4spn = 3'b000;
  localparam OpcodeC0Fld = 3'b001;
  localparam OpcodeC0Lw = 3'b010;
  localparam OpcodeC0Ld = 3'b011;
  localparam OpcodeC0Rsrvd = 3'b100;
  localparam OpcodeC0Fsd = 3'b101;
  localparam OpcodeC0Sw = 3'b110;
  localparam OpcodeC0Sd = 3'b111;

  localparam OpcodeC1 = 2'b01;
  localparam OpcodeC1Addi = 3'b000;
  localparam OpcodeC1Addiw = 3'b001;
  localparam OpcodeC1Li = 3'b010;
  localparam OpcodeC1LuiAddi16sp = 3'b011;
  localparam OpcodeC1MiscAlu = 3'b100;
  localparam OpcodeC1J = 3'b101;
  localparam OpcodeC1Beqz = 3'b110;
  localparam OpcodeC1Bnez = 3'b111;

  localparam OpcodeC2 = 2'b10;
  localparam OpcodeC2Slli = 3'b000;
  localparam OpcodeC2Fldsp = 3'b001;
  localparam OpcodeC2Lwsp = 3'b010;
  localparam OpcodeC2Ldsp = 3'b011;
  localparam OpcodeC2JalrMvAdd = 3'b100;
  localparam OpcodeC2Fsdsp = 3'b101;
  localparam OpcodeC2Swsp = 3'b110;
  localparam OpcodeC2Sdsp = 3'b111;

  typedef struct packed {
    logic [9:0] reserved;
    logic [43:0] ppn;
    logic [1:0] rsw;
    logic d;
    logic a;
    logic g;
    logic u;
    logic x;
    logic w;
    logic r;
    logic v;
  } pte_t;

  localparam logic [63:0] INSTR_ADDR_MISALIGNED = 0;
  localparam logic [63:0] INSTR_ACCESS_FAULT = 1;
  localparam logic [63:0] ILLEGAL_INSTR = 2;
  localparam logic [63:0] BREAKPOINT = 3;
  localparam logic [63:0] LD_ADDR_MISALIGNED = 4;
  localparam logic [63:0] LD_ACCESS_FAULT = 5;
  localparam logic [63:0] ST_ADDR_MISALIGNED = 6;
  localparam logic [63:0] ST_ACCESS_FAULT = 7;
  localparam logic [63:0] ENV_CALL_UMODE = 8;
  localparam logic [63:0] ENV_CALL_SMODE = 9;
  localparam logic [63:0] ENV_CALL_MMODE = 11;
  localparam logic [63:0] INSTR_PAGE_FAULT = 12;
  localparam logic [63:0] LOAD_PAGE_FAULT = 13;
  localparam logic [63:0] STORE_PAGE_FAULT = 15;

  localparam int unsigned IRQ_S_SOFT = 1;
  localparam int unsigned IRQ_M_SOFT = 3;
  localparam int unsigned IRQ_S_TIMER = 5;
  localparam int unsigned IRQ_M_TIMER = 7;
  localparam int unsigned IRQ_S_EXT = 9;
  localparam int unsigned IRQ_M_EXT = 11;

  localparam logic [63:0] MIP_SSIP = (1 << IRQ_S_SOFT);
  localparam logic [63:0] MIP_MSIP = (1 << IRQ_M_SOFT);
  localparam logic [63:0] MIP_STIP = (1 << IRQ_S_TIMER);
  localparam logic [63:0] MIP_MTIP = (1 << IRQ_M_TIMER);
  localparam logic [63:0] MIP_SEIP = (1 << IRQ_S_EXT);
  localparam logic [63:0] MIP_MEIP = (1 << IRQ_M_EXT);

  localparam logic [63:0] S_SW_INTERRUPT = (1 << 63) | IRQ_S_SOFT;
  localparam logic [63:0] M_SW_INTERRUPT = (1 << 63) | IRQ_M_SOFT;
  localparam logic [63:0] S_TIMER_INTERRUPT = (1 << 63) | IRQ_S_TIMER;
  localparam logic [63:0] M_TIMER_INTERRUPT = (1 << 63) | IRQ_M_TIMER;
  localparam logic [63:0] S_EXT_INTERRUPT = (1 << 63) | IRQ_S_EXT;
  localparam logic [63:0] M_EXT_INTERRUPT = (1 << 63) | IRQ_M_EXT;

  typedef enum logic [11:0] {

    CSR_FFLAGS = 12'h001,
    CSR_FRM    = 12'h002,
    CSR_FCSR   = 12'h003,
    CSR_FTRAN  = 12'h800,

    CSR_SSTATUS    = 12'h100,
    CSR_SIE        = 12'h104,
    CSR_STVEC      = 12'h105,
    CSR_SCOUNTEREN = 12'h106,
    CSR_SSCRATCH   = 12'h140,
    CSR_SEPC       = 12'h141,
    CSR_SCAUSE     = 12'h142,
    CSR_STVAL      = 12'h143,
    CSR_SIP        = 12'h144,
    CSR_SATP       = 12'h180,

    CSR_MSTATUS    = 12'h300,
    CSR_MISA       = 12'h301,
    CSR_MEDELEG    = 12'h302,
    CSR_MIDELEG    = 12'h303,
    CSR_MIE        = 12'h304,
    CSR_MTVEC      = 12'h305,
    CSR_MCOUNTEREN = 12'h306,
    CSR_MSCRATCH   = 12'h340,
    CSR_MEPC       = 12'h341,
    CSR_MCAUSE     = 12'h342,
    CSR_MTVAL      = 12'h343,
    CSR_MIP        = 12'h344,
    CSR_PMPCFG0    = 12'h3A0,
    CSR_PMPADDR0   = 12'h3B0,
    CSR_MVENDORID  = 12'hF11,
    CSR_MARCHID    = 12'hF12,
    CSR_MIMPID     = 12'hF13,
    CSR_MHARTID    = 12'hF14,
    CSR_MCYCLE     = 12'hB00,
    CSR_MINSTRET   = 12'hB02,
    CSR_DCACHE     = 12'h701,
    CSR_ICACHE     = 12'h700,

    CSR_TSELECT = 12'h7A0,
    CSR_TDATA1  = 12'h7A1,
    CSR_TDATA2  = 12'h7A2,
    CSR_TDATA3  = 12'h7A3,
    CSR_TINFO   = 12'h7A4,

    CSR_DCSR      = 12'h7b0,
    CSR_DPC       = 12'h7b1,
    CSR_DSCRATCH0 = 12'h7b2,
    CSR_DSCRATCH1 = 12'h7b3,

    CSR_CYCLE   = 12'hC00,
    CSR_TIME    = 12'hC01,
    CSR_INSTRET = 12'hC02,

    CSR_L1_ICACHE_MISS = 12'hC03,
    CSR_L1_DCACHE_MISS = 12'hC04,
    CSR_ITLB_MISS      = 12'hC05,
    CSR_DTLB_MISS      = 12'hC06,
    CSR_LOAD           = 12'hC07,
    CSR_STORE          = 12'hC08,
    CSR_EXCEPTION      = 12'hC09,
    CSR_EXCEPTION_RET  = 12'hC0A,
    CSR_BRANCH_JUMP    = 12'hC0B,
    CSR_CALL           = 12'hC0C,
    CSR_RET            = 12'hC0D,
    CSR_MIS_PREDICT    = 12'hC0E,
    CSR_SB_FULL        = 12'hC0F,
    CSR_IF_EMPTY       = 12'hC10
  } csr_reg_t;

  localparam logic [63:0] SSTATUS_UIE = 64'h00000001;
  localparam logic [63:0] SSTATUS_SIE = 64'h00000002;
  localparam logic [63:0] SSTATUS_SPIE = 64'h00000020;
  localparam logic [63:0] SSTATUS_SPP = 64'h00000100;
  localparam logic [63:0] SSTATUS_FS = 64'h00006000;
  localparam logic [63:0] SSTATUS_XS = 64'h00018000;
  localparam logic [63:0] SSTATUS_SUM = 64'h00040000;
  localparam logic [63:0] SSTATUS_MXR = 64'h00080000;
  localparam logic [63:0] SSTATUS_UPIE = 64'h00000010;
  localparam logic [63:0] SSTATUS_UXL = 64'h0000000300000000;
  localparam logic [63:0] SSTATUS64_SD = 64'h8000000000000000;
  localparam logic [63:0] SSTATUS32_SD = 64'h80000000;

  localparam logic [63:0] MSTATUS_UIE = 64'h00000001;
  localparam logic [63:0] MSTATUS_SIE = 64'h00000002;
  localparam logic [63:0] MSTATUS_HIE = 64'h00000004;
  localparam logic [63:0] MSTATUS_MIE = 64'h00000008;
  localparam logic [63:0] MSTATUS_UPIE = 64'h00000010;
  localparam logic [63:0] MSTATUS_SPIE = 64'h00000020;
  localparam logic [63:0] MSTATUS_HPIE = 64'h00000040;
  localparam logic [63:0] MSTATUS_MPIE = 64'h00000080;
  localparam logic [63:0] MSTATUS_SPP = 64'h00000100;
  localparam logic [63:0] MSTATUS_HPP = 64'h00000600;
  localparam logic [63:0] MSTATUS_MPP = 64'h00001800;
  localparam logic [63:0] MSTATUS_FS = 64'h00006000;
  localparam logic [63:0] MSTATUS_XS = 64'h00018000;
  localparam logic [63:0] MSTATUS_MPRV = 64'h00020000;
  localparam logic [63:0] MSTATUS_SUM = 64'h00040000;
  localparam logic [63:0] MSTATUS_MXR = 64'h00080000;
  localparam logic [63:0] MSTATUS_TVM = 64'h00100000;
  localparam logic [63:0] MSTATUS_TW = 64'h00200000;
  localparam logic [63:0] MSTATUS_TSR = 64'h00400000;
  localparam logic [63:0] MSTATUS32_SD = 64'h80000000;
  localparam logic [63:0] MSTATUS_UXL = 64'h0000000300000000;
  localparam logic [63:0] MSTATUS_SXL = 64'h0000000C00000000;
  localparam logic [63:0] MSTATUS64_SD = 64'h8000000000000000;

  typedef enum logic [2:0] {
    CSRRW  = 3'h1,
    CSRRS  = 3'h2,
    CSRRC  = 3'h3,
    CSRRWI = 3'h5,
    CSRRSI = 3'h6,
    CSRRCI = 3'h7
  } csr_op_t;

  typedef struct packed {
    logic [1:0] rw;
    priv_lvl_t  priv_lvl;
    logic [7:0] address;
  } csr_addr_t;

  typedef union packed {
    csr_reg_t  address;
    csr_addr_t csr_decode;
  } csr_t;

  typedef struct packed {
    logic [31:15] reserved;
    logic [6:0]   fprec;
    logic [2:0]   frm;
    logic [4:0]   fflags;
  } fcsr_t;

  typedef struct packed {
    logic [31:28] xdebugver;
    logic [27:16] zero2;
    logic         ebreakm;
    logic         zero1;
    logic         ebreaks;
    logic         ebreaku;
    logic         stepie;
    logic         stopcount;
    logic         stoptime;
    logic [8:6]   cause;
    logic         zero0;
    logic         mprven;
    logic         nmip;
    logic         step;
    priv_lvl_t    prv;
  } dcsr_t;

  function automatic logic [31:0] jal(logic [4:0] rd, logic [20:0] imm);

    return {imm[20], imm[10:1], imm[11], imm[19:12], rd, 7'h6f};
  endfunction

  function automatic logic [31:0] jalr(logic [4:0] rd, logic [4:0] rs1, logic [11:0] offset);

    return {offset[11:0], rs1, 3'b0, rd, 7'h67};
  endfunction

  function automatic logic [31:0] andi(logic [4:0] rd, logic [4:0] rs1, logic [11:0] imm);

    return {imm[11:0], rs1, 3'h7, rd, 7'h13};
  endfunction

  function automatic logic [31:0] slli(logic [4:0] rd, logic [4:0] rs1, logic [5:0] shamt);

    return {6'b0, shamt[5:0], rs1, 3'h1, rd, 7'h13};
  endfunction

  function automatic logic [31:0] srli(logic [4:0] rd, logic [4:0] rs1, logic [5:0] shamt);

    return {6'b0, shamt[5:0], rs1, 3'h5, rd, 7'h13};
  endfunction

  function automatic logic [31:0] load(logic [2:0] size, logic [4:0] dest, logic [4:0] base,
                                       logic [11:0] offset);

    return {offset[11:0], base, size, dest, 7'h03};
  endfunction

  function automatic logic [31:0] auipc(logic [4:0] rd, logic [20:0] imm);

    return {imm[20], imm[10:1], imm[11], imm[19:12], rd, 7'h17};
  endfunction

  function automatic logic [31:0] store(logic [2:0] size, logic [4:0] src, logic [4:0] base,
                                        logic [11:0] offset);

    return {offset[11:5], src, base, size, offset[4:0], 7'h23};
  endfunction

  function automatic logic [31:0] float_load(logic [2:0] size, logic [4:0] dest, logic [4:0] base,
                                             logic [11:0] offset);

    return {offset[11:0], base, size, dest, 7'b00_001_11};
  endfunction

  function automatic logic [31:0] float_store(logic [2:0] size, logic [4:0] src, logic [4:0] base,
                                              logic [11:0] offset);

    return {offset[11:5], src, base, size, offset[4:0], 7'b01_001_11};
  endfunction

  function automatic logic [31:0] csrw(csr_reg_t csr, logic [4:0] rs1);

    return {csr, rs1, 3'h1, 5'h0, 7'h73};
  endfunction

  function automatic logic [31:0] csrr(csr_reg_t csr, logic [4:0] dest);

    return {csr, 5'h0, 3'h2, dest, 7'h73};
  endfunction

  function automatic logic [31:0] ebreak();
    return 32'h00100073;
  endfunction

  function automatic logic [31:0] nop();
    return 32'h00000013;
  endfunction

  function automatic logic [31:0] illegal();
    return 32'h00000000;
  endfunction

  function string spikeCommitLog(logic [63:0] pc, priv_lvl_t priv_lvl, logic [31:0] instr,
                                 logic [4:0] rd, logic [63:0] result, logic rd_fpr);
    string rd_s;
    automatic string rf_s = rd_fpr ? "f" : "x";

    if (rd < 10) rd_s = $sformatf("%s %0d", rf_s, rd);
    else rd_s = $sformatf("%s%0d", rf_s, rd);

    if (rd_fpr || rd != 0) begin
      return $sformatf("%d 0x%h (0x%h) %s 0x%h\n", priv_lvl, pc, instr, rd_s, result);
    end else begin
      return $sformatf("%d 0x%h (0x%h)\n", priv_lvl, pc, instr);
    end
  endfunction

  typedef struct {
    byte priv;
    longint unsigned pc;
    byte is_fp;
    byte rd;
    longint unsigned data;
    int unsigned instr;
    byte was_exception;
  } commit_log_t;

endpackage
