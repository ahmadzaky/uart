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


entity rx_fsm is              
	port(                            
            clk_i    : in std_logic;                                             
            rstn_i   : in std_logic;   
            baud_i   : in std_logic;  
            rx_i     : in std_logic;  
            start_o  : out std_logic;  
            valid_o  : out std_logic; 
            byte_o   : out std_logic_vector(7 downto 0);    
            busy_o   : out std_logic      
         
    );
end entity rx_fsm;

architecture rtl of rx_fsm is

type states_type is (IDLE, STARTBYTE, BYTES, STOPBYTES);


signal cur_state    : states_type := IDLE;
signal next_state   : states_type := IDLE;
signal rxbuff       : std_logic_vector(8 downto 0);
signal rxbuffd      : std_logic_vector(8 downto 0);
signal count        : std_logic_vector(3 downto 0);
signal start_v      : std_logic;
signal byte_v       : std_logic;
signal receiving_v  : std_logic;
signal receiving_d  : std_logic;
signal s_rx         : std_logic;
signal s_rxd        : std_logic;
signal s_rxdd       : std_logic;
signal clk_baud     : std_logic;
signal clk_baud_d   : std_logic;
signal rx_baud      : std_logic;


    attribute mark_debug : string;
    attribute mark_debug of rxbuffd : signal is "true";
    attribute mark_debug of cur_state   : signal is "true";
    attribute mark_debug of s_rxd   : signal is "true";

begin 




    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            cur_state <= IDLE;
        elsif clk_i'event and clk_i = '0' then 
            cur_state <= next_state;
        end if;
    end process;

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            next_state  <= IDLE;
            receiving_v <= '0';
            byte_o <= (others=>'0');
        elsif clk_i'event and clk_i = '1' then 
            case cur_state is
                when IDLE =>
                    if start_v = '1' then
                        receiving_v <= '1';
                        next_state  <= STARTBYTE;
                    else
                        next_state  <= IDLE;
                    end if;
                when STARTBYTE =>
                    receiving_v <= '1';
                    if rx_baud = '1' then
                        next_state  <= BYTES;
                    else
                        next_state  <= STARTBYTE;
                    end if;
                when BYTES =>
                    receiving_v <= '1';
                    if count = "0000" and s_rxd = '1'  then
                        next_state  <= STOPBYTES;
                    else
                        next_state  <= BYTES;
                    end if;
                when STOPBYTES =>
                    if rx_baud = '1' then
                        receiving_v <= '0';
                        next_state  <= IDLE;
                        byte_o <= rxbuffd(8 downto 1);
                    else   
                        receiving_v <= '1';
                        byte_o <= (others=>'0');
                        next_state  <= STOPBYTES;
                    end if;
                when others =>
                    next_state  <= IDLE;
            end case;
        end if;
    end process;

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            s_rx    <= '1';
            s_rxd   <= '1';
            s_rxdd  <= '1';
        elsif clk_i'event and clk_i = '1' then 
            if baud_i = '1' then
                s_rx    <= rx_i;
            end if;
            s_rxd   <= s_rx;
            s_rxdd  <= s_rxd;
        end if;
    end process;
    
    rx_baud <= clk_baud when (clk_baud_d = '0') else '0';
    byte_v  <= receiving_d when (receiving_v = '0') else '0';

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            clk_baud   <= '0';
            clk_baud_d <= '0';
        elsif clk_i'event and clk_i = '1' then 
            if baud_i = '1' then 
                if receiving_v = '1' then
                    clk_baud <= not clk_baud;
                else
                    clk_baud   <= '0';
                end if;
            end if;
            clk_baud_d <= clk_baud;
        end if;
    end process;


    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            receiving_d <= '0';
            valid_o     <= '0';
        elsif clk_i'event and clk_i = '1' then 
            receiving_d <= receiving_v;
            valid_o     <= byte_v;
        end if;
    end process;


    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            start_v <= '0';
        elsif clk_i'event and clk_i = '1' then 
            if cur_state = IDLE then
                if s_rxd = '0' then
                    start_v <= s_rxdd;
                end if;
            else
                start_v <= '0';
            end if;
        end if;
    end process;
    
    start_o <= start_v;

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            count  <= (others => '0');
        elsif clk_i'event and clk_i = '1' then 
            if cur_state = IDLE then
                count  <= conv_std_logic_vector(9,4);
            else
                if count > "0000" then
                    if rx_baud = '1' then   
                        count  <= count-1;
                    end if;
                end if;
            end if;
        end if;
    end process;


   process(rstn_i, clk_i)
   begin
       if rstn_i = '0' then
           rxbuff <= (others => '1');
       elsif clk_i'event and clk_i = '1' then 
           if cur_state = IDLE then
                rxbuff <= (others => '1');
           elsif cur_state = BYTES then
                if rx_baud = '1' then
                    rxbuff <= s_rxd & rxbuff(8 downto 1);
                end if;
           end if;
       end if;
   end process;

   process(rstn_i, clk_i)
   begin
       if rstn_i = '0' then
           busy_o <= '0';
       elsif clk_i'event and clk_i = '1' then 
           if cur_state = IDLE then
                busy_o <= '0';
           else
                busy_o <= '1';
           end if;
       end if;
   end process;
  
  

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            rxbuffd    <= (others => '0');
        elsif clk_i'event and clk_i = '1' then 
            rxbuffd <= rxbuff;
        end if;
    end process;
  

end architecture;
		
