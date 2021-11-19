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


entity uart_top is              
    generic( BAUD_DIV   : std_logic_vector(5 downto 0) :=  "000000");    
	port(                            
            clk_i    : in std_logic;                                             
            rstn_i   : in std_logic;   
            
            valid_i  : in std_logic;  
            byte_i   : in std_logic_vector(7 downto 0);    
            byte_o   : out std_logic_vector(7 downto 0);    
            valid_o  : out std_logic;       
            txen_o   : out std_logic;        
            rxen_o   : out std_logic;   
            
            rx_i     : in std_logic;        
            tx_o     : out std_logic       
         
    );
end entity uart_top;

architecture rtl of uart_top is

    component baud_gen
        generic( BAUD_DIV   : std_logic_vector(5 downto 0) :=  "000000");                  
        port(                            
                clk_i      : in std_logic;                                             
                rstn_i     : in std_logic;                                            
                rstart_i   : in std_logic;    
                baud_rx_o  : out std_logic;     
                baud_tx_o  : out std_logic      
        );
    end component;

    component uart_tx              
        port(                            
                clk_i    : in std_logic;                                             
                rstn_i   : in std_logic;   
                baud_i   : in std_logic;  
                valid_i  : in std_logic;  
                byte_i   : in std_logic_vector(7 downto 0);    
                busy_o   : out std_logic;        
                tx_o     : out std_logic       
            
        );
    end component;
    
    component uart_rx          
	port(                            
            clk_i    : in std_logic;                                             
            rstn_i   : in std_logic;   
            baud_i   : in std_logic;  
            rx_i     : in std_logic;  
            valid_o  : out std_logic;  
            byte_o   : out std_logic_vector(7 downto 0);    
            busy_o   : out std_logic      
    );
    end component;
    
    component rx_fsm           
	port(                            
            clk_i    : in std_logic;                                             
            rstn_i   : in std_logic;   
            baud_i   : in std_logic;  
            rx_i     : in std_logic;  
            valid_o  : out std_logic;  
            start_o  : out std_logic;  
            byte_o   : out std_logic_vector(7 downto 0);    
            busy_o   : out std_logic      
         
    );
end component;
    
    component uart_buff  
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
    end component;

    signal s_baud_rx_o : std_logic;
    signal s_baud_tx_o : std_logic;
    signal s_tx_busy   : std_logic;
    signal s_rx_busy   : std_logic;
    signal s_valid     : std_logic;
    signal s_validfifo : std_logic;
    signal start_v     : std_logic;
    signal s_txfifo    : std_logic_vector(7 downto 0);

    attribute mark_debug : string;
    attribute mark_debug of rx_i : signal is "true";
    attribute mark_debug of tx_o : signal is "true";
    attribute mark_debug of byte_o : signal is "true";


begin 

        BDT : baud_gen
        generic map( BAUD_DIV   => BAUD_DIV)               
        port map(                          
                clk_i      => clk_i,                                       
                rstn_i     => rstn_i,                                     
                rstart_i   => '0', 
                baud_tx_o  => s_baud_tx_o    
        );
        
        BDR : baud_gen 
        generic map( BAUD_DIV   => BAUD_DIV)               
        port map(                          
                clk_i      => clk_i,                                       
                rstn_i     => rstn_i,                                 
                rstart_i   => '0', 
                baud_rx_o  => s_baud_rx_o   
        );
        
        
        TX : uart_tx              
        port map(                            
                clk_i    =>   clk_i,                                       
                rstn_i   =>   rstn_i,
                baud_i   =>   s_baud_tx_o,
                valid_i  =>   s_validfifo,
                byte_i   =>   s_txfifo,  
                busy_o   =>   s_tx_busy,      
                tx_o     =>   tx_o 
        );
    
    
        RX :  rx_fsm          
        port map(                            
                clk_i    =>  clk_i,                                             
                rstn_i   =>  rstn_i,        
                baud_i   =>  s_baud_rx_o,   
                rx_i     =>  rx_i,      
                valid_o  =>  valid_o, 
                start_o  =>  start_v,
                byte_o   =>  byte_o, 
                busy_o   =>  s_rx_busy  
        );
        
        
    
        BF : uart_buff  
        generic map( buffsize => 8)
        port map(                            
                clk_i    => clk_i,                                    
                rstn_i   => rstn_i, 
                byte_i   => byte_i, 
                valid_i  => valid_i, 
                busy     => s_tx_busy,
                valid_o  => s_validfifo, 
                byte_o   => s_txfifo 
        );    
    
    txen_o <= s_tx_busy;
    rxen_o <= s_tx_busy;
    
    

end architecture;
		
