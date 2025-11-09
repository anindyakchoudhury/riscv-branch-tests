package std_cache_pkg;

    
    localparam DCACHE_BYTE_OFFSET = $clog2(ariane_pkg::DCACHE_LINE_WIDTH/8);
    localparam DCACHE_NUM_WORDS   = 2**(ariane_pkg::DCACHE_INDEX_WIDTH-DCACHE_BYTE_OFFSET);
    localparam DCACHE_DIRTY_WIDTH = ariane_pkg::DCACHE_SET_ASSOC*2;
    

    typedef struct packed {
        logic [1:0]      id;     
        logic            valid;
        logic            we;
        logic [55:0]     addr;
        logic [7:0][7:0] wdata;
        logic [7:0]      be;
    } mshr_t;

    typedef struct packed {
        logic         valid;
        logic [63:0]  addr;
        logic [7:0]   be;
        logic [1:0]   size;
        logic         we;
        logic [63:0]  wdata;
        logic         bypass;
    } miss_req_t;

    typedef struct packed {
        logic [ariane_pkg::DCACHE_TAG_WIDTH-1:0]  tag;    
        logic [ariane_pkg::DCACHE_LINE_WIDTH-1:0] data;   
        logic                                     valid;  
        logic                                     dirty;  
    } cache_line_t;

    
    typedef struct packed {
        logic [(ariane_pkg::DCACHE_TAG_WIDTH+7)/8-1:0]  tag;    
        logic [(ariane_pkg::DCACHE_LINE_WIDTH+7)/8-1:0] data;   
        logic [ariane_pkg::DCACHE_SET_ASSOC-1:0]        vldrty; 
    } cl_be_t;

    
    function automatic logic [$clog2(ariane_pkg::DCACHE_SET_ASSOC)-1:0] one_hot_to_bin (
        input logic [ariane_pkg::DCACHE_SET_ASSOC-1:0] in
    );
        for (int unsigned i = 0; i < ariane_pkg::DCACHE_SET_ASSOC; i++) begin
            if (in[i])
                return i;
        end
    endfunction
    
    function automatic logic [ariane_pkg::DCACHE_SET_ASSOC-1:0] get_victim_cl (
        input logic [ariane_pkg::DCACHE_SET_ASSOC-1:0] valid_dirty
    );
        
        logic [ariane_pkg::DCACHE_SET_ASSOC-1:0] oh = '0;
        for (int unsigned i = 0; i < ariane_pkg::DCACHE_SET_ASSOC; i++) begin
            if (valid_dirty[i]) begin
                oh[i] = 1'b1;
                return oh;
            end
        end
    endfunction
endpackage : std_cache_pkg

