library verilog;
use verilog.vl_types.all;
entity pipelinedcpu is
    port(
        clk             : in     vl_logic;
        resetn          : in     vl_logic;
        instr           : in     vl_logic_vector(31 downto 0);
        readdata        : in     vl_logic_vector(31 downto 0);
        MemWrite        : out    vl_logic;
        PC              : out    vl_logic_vector(31 downto 0);
        aluout          : out    vl_logic_vector(31 downto 0);
        writedata       : out    vl_logic_vector(31 downto 0);
        reg_sel         : in     vl_logic_vector(4 downto 0);
        reg_data        : out    vl_logic_vector(31 downto 0)
    );
end pipelinedcpu;
