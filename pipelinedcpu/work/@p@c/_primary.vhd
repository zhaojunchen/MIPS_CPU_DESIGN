library verilog;
use verilog.vl_types.all;
entity PC is
    port(
        clk             : in     vl_logic;
        clrn            : in     vl_logic;
        NPC             : in     vl_logic_vector(31 downto 0);
        PC              : out    vl_logic_vector(31 downto 0)
    );
end PC;
