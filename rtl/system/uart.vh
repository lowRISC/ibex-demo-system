`ifndef UART
`define UART

`include "sync_fifo.v"
`include "async_fifo.v"
`include "uart_rx.v"
`include "uart_tx.v"

// If need be to use asynchronous FIFOs, uncomment.
//`define ASYNC

`endif