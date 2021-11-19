----------------------------------------------------------------------------------
-- Engineer: AZR
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: 
-- Target Devices: xc7a35t
-- Tool Versions: 16.1
-- Description: core
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity uart_buff is    
    generic( buffsize : integer := 8);
	port(                            
            clk_i    : in std_logic;                                             
            rstn_i   : in std_logic;   
            byte_i   : in std_logic_vector(7 downto 0);   
            valid_i  : in std_logic;   
            busy     : in std_logic;  
            valid_o  : out std_logic;  
            byte_o   : out std_logic_vector(7 downto 0)   
         
    );
end entity uart_buff;

architecture rtl of uart_buff is

type mem is array (0 to buffsize-1) of std_logic_vector(7 downto 0);
 
signal txbuff    : mem;
signal count     : integer range 0 to buffsize-1;
signal s_valid   : std_logic;
signal s_vld_d   : std_logic;
signal s_vld_dd  : std_logic;
signal s_vld_v   : std_logic;
signal s_busy_d  : std_logic;
signal s_busy_dd : std_logic;
signal s_busy_ddd: std_logic;
signal s_busy_v  : std_logic;



    attribute mark_debug : string;
    attribute mark_debug of txbuff : signal is "true";
    attribute mark_debug of byte_o : signal is "true";
    attribute mark_debug of byte_i : signal is "true";
    attribute mark_debug of count  : signal is "true";
    
    
begin 


    valid_o <= s_valid;
    
    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            s_vld_d    <= '0';
            s_vld_dd   <= '0';
            s_busy_d   <= '0';
            s_busy_dd  <= '0';
            s_busy_ddd <= '0';
        elsif clk_i'event and clk_i = '0' then 
            s_vld_d    <= valid_i;
            s_vld_dd   <= s_vld_d;
            s_busy_d   <= busy;
            s_busy_dd  <= s_busy_d;
            s_busy_ddd <= s_busy_dd;
        end if;
    end process;
    
    s_vld_v  <= s_vld_d  when (s_vld_dd = '0') else '0';
    s_busy_v <= s_busy_dd when (s_busy_d = '0') else '0';
    
    
    
    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            s_valid   <= '0';
        elsif clk_i'event and clk_i = '0' then 
            if s_busy_ddd = '0' then
                if count > 0 then
                    s_valid <= '1';
                end if;
            else
                s_valid   <= '0';  
            end if;
        end if;
    end process;
    
    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            count <= 0;
        elsif clk_i'event and clk_i = '0' then 
            if s_vld_v = '1' then
                if count < buffsize-1 then
                    count    <= count+1;
                end if;
            elsif s_busy_v = '1' then
                if count > 0 then
                    count <= count-1;
                end if;    
            end if;
        end if;
    end process;
    
    
    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then        
            for i in 0 to buffsize-1 LOOP
                txbuff(i) <= (others => '0');
            end loop;
        elsif clk_i'event and clk_i = '0' then 
            if s_vld_v = '1' then
                txbuff(count) <= byte_i;
            elsif s_busy_v = '1' then   
                for i in 0 to buffsize-2 LOOP
                    txbuff(i) <= txbuff(i+1);
                end loop;   
            end if;
        end if;
    end process;
    
   byte_o <= txbuff(0);

end architecture;
		
