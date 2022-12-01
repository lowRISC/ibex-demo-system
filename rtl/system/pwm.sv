module pwm #(
  parameter int CtrSize = 8,
  parameter int IOLength = 1
) (
  input logic                 clk_sys_i,
  input logic                 rst_sys_ni,

  input  logic [CtrSize-1:0]  pulse_width_i,
  input  logic [IOLength-1:0] unmodulated_i,

  output logic [IOLength-1:0] modulated_o
);
  logic [CtrSize-1:0] counter;

  always_ff @(posedge clk_sys_i) begin
    if (!rst_sys_ni) begin
      counter <= 'b0;
      modulated_o <= 'b0;
    end else begin
      counter <= counter + 1;
      //TODO should be >=
      if (pulse_width_i > counter) begin
        modulated_o <= unmodulated_i;
      end else begin
        modulated_o <= 'b0;
      end
    end
  end
endmodule