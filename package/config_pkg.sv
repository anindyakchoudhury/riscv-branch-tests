package config_pkg;

  localparam int unsigned ILEN = 32;
  localparam int unsigned NRET = 1;

  typedef enum {

    NOC_TYPE_AXI4_ATOP,

    NOC_TYPE_L15_BIG_ENDIAN,
    NOC_TYPE_L15_LITTLE_ENDIAN
  } noc_type_e;

  typedef enum logic [2:0] {
    WB = 0,
    WT = 1,
    HPDCACHE_WT = 2,
    HPDCACHE_WB = 3,
    HPDCACHE_WT_WB = 4
  } cache_type_t;

  typedef enum logic {
    BHT = 0,
    PH_BHT = 1
  } bp_type_t;

  typedef enum logic [3:0] {
    ModeOff  = 0,
    ModeSv32 = 1,
    ModeSv39 = 8,
    ModeSv48 = 9,
    ModeSv57 = 10,
    ModeSv64 = 11
  } vm_mode_t;

  typedef enum {
    COPRO_NONE,
    COPRO_EXAMPLE
  } copro_type_t;

  localparam NrMaxRules = 16;

  typedef struct packed {

    int unsigned XLEN;

    int unsigned VLEN;

    bit RVA;

    bit RVB;

    bit ZKN;

    bit RVV;

    bit RVC;

    bit RVH;

    bit RVZCB;

    bit RVZCMP;

    bit RVZCMT;

    bit RVZiCond;

    bit RVZicntr;

    bit RVZihpm;

    bit RVF;

    bit RVD;

    bit XF16;

    bit XF16ALT;

    bit XF8;

    bit XFVec;

    bit PerfCounterEn;

    bit MmuPresent;

    bit RVS;

    bit RVU;

    bit SoftwareInterruptEn;

    bit DebugEn;

    logic [63:0] DmBaseAddress;

    logic [63:0] HaltAddress;

    logic [63:0] ExceptionAddress;

    bit TvalEn;

    bit DirectVecOnly;

    int unsigned NrPMPEntries;

    logic [63:0][63:0] PMPCfgRstVal;

    logic [63:0][63:0] PMPAddrRstVal;

    bit [63:0] PMPEntryReadOnly;

    bit PMPNapotEn;

    int unsigned NrNonIdempotentRules;

    logic [NrMaxRules-1:0][63:0] NonIdempotentAddrBase;

    logic [NrMaxRules-1:0][63:0] NonIdempotentLength;

    int unsigned NrExecuteRegionRules;

    logic [NrMaxRules-1:0][63:0] ExecuteRegionAddrBase;

    logic [NrMaxRules-1:0][63:0] ExecuteRegionLength;

    int unsigned NrCachedRegionRules;

    logic [NrMaxRules-1:0][63:0] CachedRegionAddrBase;

    logic [NrMaxRules-1:0][63:0] CachedRegionLength;

    bit CvxifEn;

    copro_type_t CoproType;

    noc_type_e NOCType;

    int unsigned AxiAddrWidth;

    int unsigned AxiDataWidth;

    int unsigned AxiIdWidth;

    int unsigned AxiUserWidth;

    bit AxiBurstWriteEn;

    int unsigned MemTidWidth;

    int unsigned IcacheByteSize;

    int unsigned IcacheSetAssoc;

    int unsigned IcacheLineWidth;

    cache_type_t DCacheType;

    int unsigned DcacheIdWidth;

    int unsigned DcacheByteSize;

    int unsigned DcacheSetAssoc;

    int unsigned DcacheLineWidth;

    bit DcacheFlushOnFence;

    bit DcacheInvalidateOnFlush;

    int unsigned DataUserEn;

    int unsigned WtDcacheWbufDepth;

    int unsigned FetchUserEn;

    int unsigned FetchUserWidth;

    bit FpgaEn;

    bit FpgaAlteraEn;

    bit TechnoCut;

    bit SuperscalarEn;

    int unsigned NrCommitPorts;

    int unsigned NrLoadPipeRegs;

    int unsigned NrStorePipeRegs;

    int unsigned NrScoreboardEntries;

    int unsigned NrLoadBufEntries;

    int unsigned MaxOutstandingStores;

    int unsigned RASDepth;

    int unsigned BTBEntries;

    bp_type_t BPType;

    int unsigned BHTEntries;

    int unsigned BHTHist;

    int unsigned InstrTlbEntries;

    int unsigned DataTlbEntries;

    bit unsigned UseSharedTlb;

    int unsigned SharedTlbDepth;
  } cva6_user_cfg_t;

  typedef struct packed {
    int unsigned XLEN;
    int unsigned VLEN;
    int unsigned PLEN;
    int unsigned GPLEN;
    bit IS_XLEN32;
    bit IS_XLEN64;
    int unsigned XLEN_ALIGN_BYTES;
    int unsigned ASID_WIDTH;
    int unsigned VMID_WIDTH;

    bit FpgaEn;
    bit FpgaAlteraEn;
    bit TechnoCut;

    bit          SuperscalarEn;
    int unsigned NrCommitPorts;
    int unsigned NrIssuePorts;
    bit          SpeculativeSb;

    int unsigned NrLoadPipeRegs;
    int unsigned NrStorePipeRegs;

    int unsigned AxiAddrWidth;
    int unsigned AxiDataWidth;
    int unsigned AxiIdWidth;
    int unsigned AxiUserWidth;
    int unsigned MEM_TID_WIDTH;
    int unsigned NrLoadBufEntries;
    bit          RVF;
    bit          RVD;
    bit          XF16;
    bit          XF16ALT;
    bit          XF8;
    bit          RVA;
    bit          RVB;
    bit          ZKN;
    bit          RVV;
    bit          RVC;
    bit          RVH;
    bit          RVZCB;
    bit          RVZCMP;
    bit          RVZCMT;
    bit          XFVec;
    bit          CvxifEn;
    copro_type_t CoproType;
    bit          RVZiCond;
    bit          RVZicntr;
    bit          RVZihpm;

    int unsigned NR_SB_ENTRIES;
    int unsigned TRANS_ID_BITS;

    bit          FpPresent;
    bit          NSX;
    int unsigned FLen;
    bit          RVFVec;
    bit          XF16Vec;
    bit          XF16ALTVec;
    bit          XF8Vec;
    int unsigned NrRgprPorts;
    int unsigned NrWbPorts;
    bit          EnableAccelerator;
    bit          PerfCounterEn;
    bit          MmuPresent;
    bit          RVS;
    bit          RVU;
    bit          SoftwareInterruptEn;

    logic [63:0] HaltAddress;
    logic [63:0] ExceptionAddress;
    int unsigned RASDepth;
    int unsigned BTBEntries;
    bp_type_t    BPType;
    int unsigned BHTEntries;
    int unsigned BHTHist;
    int unsigned InstrTlbEntries;
    int unsigned DataTlbEntries;
    bit unsigned UseSharedTlb;
    int unsigned SharedTlbDepth;
    int unsigned VpnLen;
    int unsigned PtLevels;

    logic [63:0]                 DmBaseAddress;
    bit                          TvalEn;
    bit                          DirectVecOnly;
    int unsigned                 NrPMPEntries;
    logic [63:0][63:0]           PMPCfgRstVal;
    logic [63:0][63:0]           PMPAddrRstVal;
    bit [63:0]                   PMPEntryReadOnly;
    bit                          PMPNapotEn;
    noc_type_e                   NOCType;
    int unsigned                 NrNonIdempotentRules;
    logic [NrMaxRules-1:0][63:0] NonIdempotentAddrBase;
    logic [NrMaxRules-1:0][63:0] NonIdempotentLength;
    int unsigned                 NrExecuteRegionRules;
    logic [NrMaxRules-1:0][63:0] ExecuteRegionAddrBase;
    logic [NrMaxRules-1:0][63:0] ExecuteRegionLength;
    int unsigned                 NrCachedRegionRules;
    logic [NrMaxRules-1:0][63:0] CachedRegionAddrBase;
    logic [NrMaxRules-1:0][63:0] CachedRegionLength;
    int unsigned                 MaxOutstandingStores;
    bit                          DebugEn;
    bit                          NonIdemPotenceEn;
    bit                          AxiBurstWriteEn;

    int unsigned ICACHE_SET_ASSOC;
    int unsigned ICACHE_SET_ASSOC_WIDTH;
    int unsigned ICACHE_INDEX_WIDTH;
    int unsigned ICACHE_TAG_WIDTH;
    int unsigned ICACHE_LINE_WIDTH;
    int unsigned ICACHE_USER_LINE_WIDTH;
    cache_type_t DCacheType;
    int unsigned DcacheIdWidth;
    int unsigned DCACHE_SET_ASSOC;
    int unsigned DCACHE_SET_ASSOC_WIDTH;
    int unsigned DCACHE_INDEX_WIDTH;
    int unsigned DCACHE_TAG_WIDTH;
    int unsigned DCACHE_LINE_WIDTH;
    int unsigned DCACHE_USER_LINE_WIDTH;
    int unsigned DCACHE_USER_WIDTH;
    int unsigned DCACHE_OFFSET_WIDTH;
    int unsigned DCACHE_NUM_WORDS;

    int unsigned DCACHE_MAX_TX;

    bit DcacheFlushOnFence;
    bit DcacheInvalidateOnFlush;

    int unsigned DATA_USER_EN;
    int unsigned WtDcacheWbufDepth;
    int unsigned FETCH_USER_WIDTH;
    int unsigned FETCH_USER_EN;
    bit          AXI_USER_EN;

    int unsigned FETCH_WIDTH;
    int unsigned FETCH_ALIGN_BITS;
    int unsigned INSTR_PER_FETCH;
    int unsigned LOG2_INSTR_PER_FETCH;

    int unsigned ModeW;
    int unsigned ASIDW;
    int unsigned VMIDW;
    int unsigned PPNW;
    int unsigned GPPNW;
    vm_mode_t MODE_SV;
    int unsigned SV;
    int unsigned SVX;

    int unsigned X_NUM_RS;
    int unsigned X_ID_WIDTH;
    int unsigned X_RFR_WIDTH;
    int unsigned X_RFW_WIDTH;
    int unsigned X_NUM_HARTS;
    int unsigned X_HARTID_WIDTH;
    int unsigned X_DUALREAD;
    int unsigned X_DUALWRITE;
    int unsigned X_ISSUE_REGISTER_SPLIT;

  } cva6_cfg_t;

  localparam cva6_cfg_t cva6_cfg_empty = cva6_cfg_t'(0);

  function automatic void check_cfg(cva6_cfg_t Cfg);

    assert (Cfg.RASDepth > 0);
    assert (Cfg.BTBEntries == 0 || (2 ** $clog2(Cfg.BTBEntries) == Cfg.BTBEntries));
    assert (Cfg.BHTEntries == 0 || (2 ** $clog2(Cfg.BHTEntries) == Cfg.BHTEntries));
    assert (Cfg.NrNonIdempotentRules <= NrMaxRules);
    assert (Cfg.NrExecuteRegionRules <= NrMaxRules);
    assert (Cfg.NrCachedRegionRules <= NrMaxRules);
    assert (Cfg.NrPMPEntries <= 64);
    assert (!(Cfg.SuperscalarEn && Cfg.RVF));
    assert (Cfg.FETCH_WIDTH == 32 || Cfg.FETCH_WIDTH == 64)
    else $fatal(1, "[frontend] fetch width != not supported");

    assert (!(Cfg.RVS && !Cfg.SoftwareInterruptEn));
    assert (!(Cfg.RVH && !Cfg.SoftwareInterruptEn));
    assert (!(Cfg.RVZCMT && ~Cfg.MmuPresent));

  endfunction

  function automatic logic range_check(logic [63:0] base, logic [63:0] len, logic [63:0] address);

    return (address >= base) && (({1'b0, address}) < (65'(base) + len));
  endfunction : range_check

  function automatic logic is_inside_nonidempotent_regions(cva6_cfg_t Cfg, logic [63:0] address);
    logic [NrMaxRules-1:0] pass;
    pass = '0;
    for (int unsigned k = 0; k < Cfg.NrNonIdempotentRules; k++) begin
      pass[k] = range_check(Cfg.NonIdempotentAddrBase[k], Cfg.NonIdempotentLength[k], address);
    end
    return |pass;
  endfunction : is_inside_nonidempotent_regions

  function automatic logic is_inside_execute_regions(cva6_cfg_t Cfg, logic [63:0] address);

    logic [NrMaxRules-1:0] pass;
    if (Cfg.NrExecuteRegionRules != 0) begin
      pass = '0;
      for (int unsigned k = 0; k < Cfg.NrExecuteRegionRules; k++) begin
        pass[k] = range_check(Cfg.ExecuteRegionAddrBase[k], Cfg.ExecuteRegionLength[k], address);
      end
      return |pass;
    end else begin
      return 1;
    end
  endfunction : is_inside_execute_regions

  function automatic logic is_inside_cacheable_regions(cva6_cfg_t Cfg, logic [63:0] address);
    automatic logic [NrMaxRules-1:0] pass;
    pass = '0;
    for (int unsigned k = 0; k < Cfg.NrCachedRegionRules; k++) begin
      pass[k] = range_check(Cfg.CachedRegionAddrBase[k], Cfg.CachedRegionLength[k], address);
    end
    return |pass;
  endfunction : is_inside_cacheable_regions

endpackage
