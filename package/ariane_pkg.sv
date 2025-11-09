package ariane_pkg;

  localparam NR_SB_ENTRIES = 8;
  localparam TRANS_ID_BITS = $clog2(NR_SB_ENTRIES);

  localparam ASID_WIDTH = 1;
  localparam BTB_ENTRIES = 64;
  localparam BHT_ENTRIES = 128;
  localparam RAS_DEPTH = 2;
  localparam BITS_SATURATION_COUNTER = 2;
  localparam NR_COMMIT_PORTS = 2;

  localparam ENABLE_RENAME = 1'b0;

  localparam ISSUE_WIDTH = 1;

  localparam NR_LOAD_PIPE_REGS = 1;
  localparam NR_STORE_PIPE_REGS = 0;

  localparam int unsigned DEPTH_SPEC = 4;

  localparam int unsigned DEPTH_COMMIT = 8;

  localparam bit RVF = 1'b1;
  localparam bit RVD = 1'b1;
  localparam bit RVA = 1'b1;

  localparam bit XF16 = 1'b0;
  localparam bit XF16ALT = 1'b0;
  localparam bit XF8 = 1'b0;
  localparam bit XFVEC = 1'b0;

  localparam logic [30:0] LAT_COMP_FP32 = 'd3;
  localparam logic [30:0] LAT_COMP_FP64 = 'd4;
  localparam logic [30:0] LAT_COMP_FP16 = 'd3;
  localparam logic [30:0] LAT_COMP_FP16ALT = 'd3;
  localparam logic [30:0] LAT_COMP_FP8 = 'd2;
  localparam logic [30:0] LAT_DIVSQRT = 'd2;
  localparam logic [30:0] LAT_NONCOMP = 'd1;
  localparam logic [30:0] LAT_CONV = 'd2;

  localparam bit FP_PRESENT = RVF | RVD | XF16 | XF16ALT | XF8;

  localparam FLEN = RVD ? 64 : RVF ? 32 : XF16 ? 16 : XF16ALT ? 16 : XF8 ? 8 : 0;

  localparam bit NSX = XF16 | XF16ALT | XF8 | XFVEC;

  localparam bit RVFVEC = RVF & XFVEC & FLEN > 32;
  localparam bit XF16VEC = XF16 & XFVEC & FLEN > 16;
  localparam bit XF16ALTVEC = XF16ALT & XFVEC & FLEN > 16;
  localparam bit XF8VEC = XF8 & XFVEC & FLEN > 8;

  localparam logic [63:0] ARIANE_MARCHID = 64'd3;

  localparam logic [63:0] ISA_CODE = (RVA << 0)  
  | (1 << 2)  
  | (RVD << 3)  
  | (RVF << 5)  
  | (1 << 8)  
  | (1 << 12)  
  | (0 << 13)  
  | (1 << 18)  
  | (1 << 20)  
  | (NSX << 23)  
  | (1 << 63);

  localparam REG_ADDR_SIZE = 6;
  localparam NR_WB_PORTS = 4;

  localparam dm::hartinfo_t DebugHartInfo = '{
      zero1: '0,
      nscratch: 2,
      zero0: '0,
      dataaccess: 1'b1,
      datasize: dm::DataCount,
      dataaddr: dm::DataAddr
  };

  localparam bit ENABLE_SPIKE_COMMIT_LOG = 1'b1;

  localparam logic INVALIDATE_ON_FLUSH = 1'b1;

  localparam bit ENABLE_CYCLE_COUNT = 1'b1;

  localparam bit ENABLE_WFI = 1'b1;

  localparam bit ZERO_TVAL = 1'b0;

  localparam logic [63:0] SMODE_STATUS_READ_MASK = riscv_pkg::SSTATUS_UIE
                                                   | riscv_pkg::SSTATUS_SIE
                                                   | riscv_pkg::SSTATUS_SPIE
                                                   | riscv_pkg::SSTATUS_SPP
                                                   | riscv_pkg::SSTATUS_FS
                                                   | riscv_pkg::SSTATUS_XS
                                                   | riscv_pkg::SSTATUS_SUM
                                                   | riscv_pkg::SSTATUS_MXR
                                                   | riscv_pkg::SSTATUS_UPIE
                                                   | riscv_pkg::SSTATUS_SPIE
                                                   | riscv_pkg::SSTATUS_UXL
                                                   | riscv_pkg::SSTATUS64_SD;

  localparam logic [63:0] SMODE_STATUS_WRITE_MASK = riscv_pkg::SSTATUS_SIE
                                                    | riscv_pkg::SSTATUS_SPIE
                                                    | riscv_pkg::SSTATUS_SPP
                                                    | riscv_pkg::SSTATUS_FS
                                                    | riscv_pkg::SSTATUS_SUM
                                                    | riscv_pkg::SSTATUS_MXR;

  localparam int unsigned FETCH_FIFO_DEPTH = 8;
  localparam int unsigned FETCH_WIDTH = 32;

  localparam int unsigned INSTR_PER_FETCH = FETCH_WIDTH / 16;

  typedef struct packed {
    logic [63:0] cause;
    logic [63:0] tval;

    logic valid;
  } exception_t;

  typedef enum logic [1:0] {
    BHT,
    BTB,
    RAS
  } cf_t;

  typedef struct packed {
    logic [63:0] pc;
    logic [63:0] target_address;
    logic        is_mispredict;
    logic        is_taken;

    logic valid;
    logic clear;
    cf_t  cf_type;
  } branchpredict_t;

  typedef struct packed {
    logic        valid;
    logic [63:0] predict_address;
    logic        predict_taken;

    cf_t cf_type;
  } branchpredict_sbe_t;

  typedef struct packed {
    logic        valid;
    logic [63:0] pc;
    logic [63:0] target_address;
    logic        clear;
  } btb_update_t;

  typedef struct packed {
    logic        valid;
    logic [63:0] target_address;
  } btb_prediction_t;

  typedef struct packed {
    logic        valid;
    logic [63:0] ra;
  } ras_t;

  typedef struct packed {
    logic        valid;
    logic [63:0] pc;
    logic        mispredict;
    logic        taken;
  } bht_update_t;

  typedef struct packed {
    logic valid;
    logic taken;
    logic strongly_taken;
  } bht_prediction_t;

  typedef enum logic [3:0] {
    NONE,
    LOAD,
    STORE,
    ALU,
    CTRL_FLOW,
    MULT,
    CSR,
    FPU,
    FPU_VEC
  } fu_t;

  localparam EXC_OFF_RST = 8'h80;

  localparam int unsigned ICACHE_INDEX_WIDTH = 12;
  localparam int unsigned ICACHE_TAG_WIDTH = 44;
  localparam int unsigned ICACHE_LINE_WIDTH = 128;
  localparam int unsigned ICACHE_SET_ASSOC = 4;

  localparam int unsigned DCACHE_INDEX_WIDTH = 12;
  localparam int unsigned DCACHE_TAG_WIDTH = 44;
  localparam int unsigned DCACHE_LINE_WIDTH = 128;
  localparam int unsigned DCACHE_SET_ASSOC = 8;

  typedef enum logic [6:0] {
    ADD,
    SUB,
    ADDW,
    SUBW,

    XORL,
    ORL,
    ANDL,

    SRA,
    SRL,
    SLL,
    SRLW,
    SLLW,
    SRAW,

    LTS,
    LTU,
    GES,
    GEU,
    EQ,
    NE,

    JALR,

    SLTS,
    SLTU,

    MRET,
    SRET,
    DRET,
    ECALL,
    WFI,
    FENCE,
    FENCE_I,
    SFENCE_VMA,
    CSR_WRITE,
    CSR_READ,
    CSR_SET,
    CSR_CLEAR,

    LD,
    SD,
    LW,
    LWU,
    SW,
    LH,
    LHU,
    SH,
    LB,
    SB,
    LBU,

    AMO_LRW,
    AMO_LRD,
    AMO_SCW,
    AMO_SCD,
    AMO_SWAPW,
    AMO_ADDW,
    AMO_ANDW,
    AMO_ORW,
    AMO_XORW,
    AMO_MAXW,
    AMO_MAXWU,
    AMO_MINW,
    AMO_MINWU,
    AMO_SWAPD,
    AMO_ADDD,
    AMO_ANDD,
    AMO_ORD,
    AMO_XORD,
    AMO_MAXD,
    AMO_MAXDU,
    AMO_MIND,
    AMO_MINDU,

    MUL,
    MULH,
    MULHU,
    MULHSU,
    MULW,

    DIV,
    DIVU,
    DIVW,
    DIVUW,
    REM,
    REMU,
    REMW,
    REMUW,

    FLD,
    FLW,
    FLH,
    FLB,
    FSD,
    FSW,
    FSH,
    FSB,

    FADD,
    FSUB,
    FMUL,
    FDIV,
    FMIN_MAX,
    FSQRT,
    FMADD,
    FMSUB,
    FNMSUB,
    FNMADD,

    FCVT_F2I,
    FCVT_I2F,
    FCVT_F2F,
    FSGNJ,
    FMV_F2X,
    FMV_X2F,

    FCMP,

    FCLASS,

    VFMIN,
    VFMAX,
    VFSGNJ,
    VFSGNJN,
    VFSGNJX,
    VFEQ,
    VFNE,
    VFLT,
    VFGE,
    VFLE,
    VFGT,
    VFCPKAB_S,
    VFCPKCD_S,
    VFCPKAB_D,
    VFCPKCD_D
  } fu_op;

  typedef struct packed {
    fu_t                      fu;
    fu_op                     operator;
    logic [63:0]              operand_a;
    logic [63:0]              operand_b;
    logic [63:0]              imm;
    logic [TRANS_ID_BITS-1:0] trans_id;
  } fu_data_t;

  function automatic logic is_rs1_fpr(input fu_op op);
    if (FP_PRESENT) begin
      unique case (op) inside
        [FMUL : FNMADD], FCVT_F2I, FCVT_F2F, FSGNJ, FMV_F2X, FCMP, FCLASS, [VFMIN : VFCPKCD_D]:
        return 1'b1;
        default: return 1'b0;
      endcase
    end else return 1'b0;
  endfunction
  ;

  function automatic logic is_rs2_fpr(input fu_op op);
    if (FP_PRESENT) begin
      unique case (op) inside
        [FSD : FSB],  
        [FADD : FMIN_MAX],  
        [FMADD : FNMADD],  
        FCVT_F2F,  
        [FSGNJ : FMV_F2X],  
        FCMP,  
        [VFMIN : VFCPKCD_D]:
        return 1'b1;
        default: return 1'b0;
      endcase
    end else return 1'b0;
  endfunction
  ;

  function automatic logic is_imm_fpr(input fu_op op);
    if (FP_PRESENT) begin
      unique case (op) inside
        [FADD : FSUB], [FMADD : FNMADD], [VFCPKAB_S : VFCPKCD_D]: return 1'b1;
        default: return 1'b0;
      endcase
    end else return 1'b0;
  endfunction
  ;

  function automatic logic is_rd_fpr(input fu_op op);
    if (FP_PRESENT) begin
      unique case (op) inside
        [FLD : FLB],  
        [FADD : FNMADD],  
        FCVT_I2F,  
        FCVT_F2F,  
        FSGNJ,  
        FMV_X2F,  
        [VFMIN : VFSGNJX],  
        [VFCPKAB_S : VFCPKCD_D]:
        return 1'b1;
        default: return 1'b0;
      endcase
    end else return 1'b0;
  endfunction
  ;

  function automatic logic is_amo(fu_op op);
    case (op) inside
      [AMO_LRW : AMO_MINDU]: begin
        return 1'b1;
      end
      default: return 1'b0;
    endcase
  endfunction

  typedef struct packed {
    logic                     valid;
    logic [63:0]              vaddr;
    logic [63:0]              data;
    logic [7:0]               be;
    fu_t                      fu;
    fu_op                     operator;
    logic [TRANS_ID_BITS-1:0] trans_id;
  } lsu_ctrl_t;

  typedef struct packed {
    logic [63:0]                address;
    logic [FETCH_WIDTH-1:0]     instruction;
    branchpredict_sbe_t         branch_predict;
    logic [INSTR_PER_FETCH-1:0] bp_taken;
    logic                       page_fault;
  } frontend_fetch_t;

  typedef struct packed {
    logic [63:0]        address;
    logic [31:0]        instruction;
    branchpredict_sbe_t branch_predict;
    exception_t         ex;
  } fetch_entry_t;

  typedef struct packed {
    logic [63:0] pc;
    logic [TRANS_ID_BITS-1:0] trans_id;

    fu_t fu;
    fu_op op;
    logic [REG_ADDR_SIZE-1:0] rs1;
    logic [REG_ADDR_SIZE-1:0] rs2;
    logic [REG_ADDR_SIZE-1:0] rd;
    logic [63:0] result;

    logic               valid;
    logic               use_imm;
    logic               use_zimm;
    logic               use_pc;
    exception_t         ex;
    branchpredict_sbe_t bp;
    logic               is_compressed;

  } scoreboard_entry_t;

  typedef enum logic [3:0] {
    AMO_NONE = 4'b0000,
    AMO_LR   = 4'b0001,
    AMO_SC   = 4'b0010,
    AMO_SWAP = 4'b0011,
    AMO_ADD  = 4'b0100,
    AMO_AND  = 4'b0101,
    AMO_OR   = 4'b0110,
    AMO_XOR  = 4'b0111,
    AMO_MAX  = 4'b1000,
    AMO_MAXU = 4'b1001,
    AMO_MIN  = 4'b1010,
    AMO_MINU = 4'b1011,
    AMO_CAS1 = 4'b1100,
    AMO_CAS2 = 4'b1101
  } amo_t;

  typedef struct packed {
    logic                  valid;
    logic                  is_2M;
    logic                  is_1G;
    logic [26:0]           vpn;
    logic [ASID_WIDTH-1:0] asid;
    riscv_pkg::pte_t       content;
  } tlb_update_t;

  localparam logic [3:0] MODE_SV39 = 4'h8;
  localparam logic [3:0] MODE_OFF = 4'h0;

  localparam PPN4K_WIDTH = 38;

  typedef struct packed {
    logic        fetch_valid;
    logic [63:0] fetch_paddr;
    exception_t  fetch_exception;
  } icache_areq_i_t;

  typedef struct packed {
    logic        fetch_req;
    logic [63:0] fetch_vaddr;
  } icache_areq_o_t;

  typedef struct packed {
    logic        req;
    logic        kill_s1;
    logic        kill_s2;
    logic [63:0] vaddr;
  } icache_dreq_i_t;

  typedef struct packed {
    logic                   ready;
    logic                   valid;
    logic [FETCH_WIDTH-1:0] data;
    logic [63:0]            vaddr;
    exception_t             ex;
  } icache_dreq_o_t;

  typedef struct packed {
    logic        req;
    amo_t        amo_op;
    logic [1:0]  size;
    logic [63:0] operand_a;
    logic [63:0] operand_b;
  } amo_req_t;

  typedef struct packed {
    logic        ack;
    logic [63:0] result;
  } amo_resp_t;

  typedef struct packed {
    logic [DCACHE_INDEX_WIDTH-1:0] address_index;
    logic [DCACHE_TAG_WIDTH-1:0]   address_tag;
    logic [63:0]                   data_wdata;
    logic                          data_req;
    logic                          data_we;
    logic [7:0]                    data_be;
    logic [1:0]                    data_size;
    logic                          kill_req;
    logic                          tag_valid;
  } dcache_req_i_t;

  typedef struct packed {
    logic        data_gnt;
    logic        data_rvalid;
    logic [63:0] data_rdata;
  } dcache_req_o_t;

  function automatic logic [63:0] sext32(logic [31:0] operand);
    return {{32{operand[31]}}, operand[31:0]};
  endfunction

  function automatic logic [63:0] uj_imm(logic [31:0] instruction_i);
    return {
      {44{instruction_i[31]}}, instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0
    };
  endfunction

  function automatic logic [63:0] i_imm(logic [31:0] instruction_i);
    return {{52{instruction_i[31]}}, instruction_i[31:20]};
  endfunction

  function automatic logic [63:0] sb_imm(logic [31:0] instruction_i);
    return {
      {51{instruction_i[31]}},
      instruction_i[31],
      instruction_i[7],
      instruction_i[30:25],
      instruction_i[11:8],
      1'b0
    };
  endfunction

  function automatic logic [63:0] data_align(logic [2:0] addr, logic [63:0] data);
    case (addr)
      3'b000: return data;
      3'b001: return {data[55:0], data[63:56]};
      3'b010: return {data[47:0], data[63:48]};
      3'b011: return {data[39:0], data[63:40]};
      3'b100: return {data[31:0], data[63:32]};
      3'b101: return {data[23:0], data[63:24]};
      3'b110: return {data[15:0], data[63:16]};
      3'b111: return {data[7:0], data[63:8]};
    endcase
    return data;
  endfunction

  function automatic logic [7:0] be_gen(logic [2:0] addr, logic [1:0] size);
    case (size)
      2'b11: begin
        return 8'b1111_1111;
      end
      2'b10: begin
        case (addr[2:0])
          3'b000: return 8'b0000_1111;
          3'b001: return 8'b0001_1110;
          3'b010: return 8'b0011_1100;
          3'b011: return 8'b0111_1000;
          3'b100: return 8'b1111_0000;
        endcase
      end
      2'b01: begin
        case (addr[2:0])
          3'b000: return 8'b0000_0011;
          3'b001: return 8'b0000_0110;
          3'b010: return 8'b0000_1100;
          3'b011: return 8'b0001_1000;
          3'b100: return 8'b0011_0000;
          3'b101: return 8'b0110_0000;
          3'b110: return 8'b1100_0000;
        endcase
      end
      2'b00: begin
        case (addr[2:0])
          3'b000: return 8'b0000_0001;
          3'b001: return 8'b0000_0010;
          3'b010: return 8'b0000_0100;
          3'b011: return 8'b0000_1000;
          3'b100: return 8'b0001_0000;
          3'b101: return 8'b0010_0000;
          3'b110: return 8'b0100_0000;
          3'b111: return 8'b1000_0000;
        endcase
      end
    endcase
    return 8'b0;
  endfunction

  function automatic logic [1:0] extract_transfer_size(fu_op op);
    case (op)
      LD, SD, FLD, FSD,
            AMO_LRD,   AMO_SCD,
            AMO_SWAPD, AMO_ADDD,
            AMO_ANDD,  AMO_ORD,
            AMO_XORD,  AMO_MAXD,
            AMO_MAXDU, AMO_MIND,
            AMO_MINDU: begin
        return 2'b11;
      end
      LW, LWU, SW, FLW, FSW,
            AMO_LRW,   AMO_SCW,
            AMO_SWAPW, AMO_ADDW,
            AMO_ANDW,  AMO_ORW,
            AMO_XORW,  AMO_MAXW,
            AMO_MAXWU, AMO_MINW,
            AMO_MINWU: begin
        return 2'b10;
      end
      LH, LHU, SH, FLH, FSH: return 2'b01;
      LB, LBU, SB, FLB, FSB: return 2'b00;
      default:               return 2'b11;
    endcase
  endfunction
endpackage
