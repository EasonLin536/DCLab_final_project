`timescale 1ns/10ps
`define CYCLE 1.0
`include "makeStroke.sv"

module tb();
    logic clk,rst;
    logic [3:0] a,b,c,d;
    initial begin
        clk=1;
        rst=1;
        #(`CYCLE*0.2) rst = 1'b0;
        #(`CYCLE*1.5) rst = 1'b1;
        a=4'd2;
        b=4'd5;
        c=4'd6;
        d=4'd4;
        $display("--- TEST diff ---");
        $display("diff:%b",diff(a,b,c));
        $display("diff:%b",diff(a,b,d));

    end


    function diff;
        input [7:0] a;
        input [7:0] b;
        input [7:0] c;
        reg signed [8:0] tmp1, tmp2;
        begin
            // diff = ((a>b) ? a-b : b-a) < ((a>c) ? a-c : c-a);
            tmp1=a-b;
            tmp2=a-c;
            diff = (tmp1[8] ? (~tmp1+1) : tmp1) < (tmp2[8] ? (~tmp2+1) : tmp2);
        end
        
    endfunction

    always #(`CYCLE * 0.5) clk = ~clk;


    initial begin
        $fsdbDumpfile("makeStroke.fsdb");
        $fsdbDumpvars;
    end

    `define TIME_OUT 100
    initial #(`TIME_OUT) $finish;
endmodule