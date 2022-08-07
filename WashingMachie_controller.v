module WashingMachie_controller (
    input wire       clk,
    input wire       rst,
    input wire [1:0] clk_freq,
    input wire       coin_in,
    input wire       double_wash,
    input wire       timer_pause,
    output reg       wash_done
);

//////////state encoding///////////   
localparam  idle=3'b0,//idle
            filling_water=3'b1,//
            washing=3'b10,//
            rinsing=3'b11,//
            spining=3'b111;//

/////////internal connections/////////
reg [2:0]  state,next_state;
reg        wash_done_reg;
reg        startover;
reg        firstwash;
reg        firstdone;
reg        timer_wait;
reg [2:0]  timer;
reg [2:0]  cycle_count;//to even out the difference between the four clk configuration
reg [9:0]  u_sec;//count from 0 to 999 for 1 mili sec
reg [9:0]  m_sec;//count from 0 to 999 for 1 sec
reg [5:0]  sec;//count from 0 to 59 for 1 min

////////timer/////////
always @(posedge clk or negedge rst) 
    begin
        if (!rst) 
            begin
                timer<=3'b0;
                u_sec<=10'b0;
                m_sec<=10'b0;
                sec<=6'b0;
                cycle_count<=3'b0;
            end
        else if (startover) 
            begin
                timer<=3'b0;
                u_sec<=10'b0;
                m_sec<=10'b0;
                sec<=6'b0;
                cycle_count<=3'b0;
            end
        else if (!timer_wait)
            begin
                case (clk_freq)
                    2'b0:
                        begin
                            if (u_sec!=10'd999) 
                                begin
                                    u_sec<=u_sec+10'b1;
                                end
                            else
                                begin
                                    if (m_sec!=10'd999) 
                                        begin
                                            m_sec<=m_sec+10'b1;
                                        end
                                    else
                                        begin
                                            if (sec!=6'd59) 
                                                begin
                                                    sec<=sec+6'b1;
                                                end
                                            else
                                                begin
                                                    if (timer!=3'd5) 
                                                        begin
                                                            timer<=timer+3'b1;
                                                        end
                                                    else
                                                        begin
                                                            timer<=3'b0;
                                                        end
                                                    sec<=6'b0;
                                                end
                                            m_sec<=10'b0;
                                        end
                                    u_sec<=10'b0;
                                end
                        end
                    2'b1:
                        begin
                            if (cycle_count!=3'd1)
                                begin
                                    cycle_count<=cycle_count+3'b1;
                                end
                            else
                                begin
                                    if (u_sec!=10'd999) 
                                        begin
                                            u_sec<=u_sec+10'b1;
                                        end
                                    else
                                        begin
                                            if (m_sec!=10'd999) 
                                                begin
                                                    m_sec<=m_sec+10'b1;
                                                end
                                            else
                                                begin
                                                    if (sec!=6'd59) 
                                                        begin
                                                            sec<=sec+6'b1;
                                                        end
                                                    else
                                                        begin
                                                            if (timer!=3'd5) 
                                                                begin
                                                                    timer<=timer+3'b1;
                                                                end
                                                            else
                                                                begin
                                                                    timer<=3'b0;
                                                                end
                                                            sec<=6'b0;
                                                        end
                                                    m_sec<=10'b0;
                                                end
                                            u_sec<=10'b0;
                                        end
                                end
                        end

                    2'b10:
                        begin
                            if (cycle_count!=3'd3)
                                begin
                                    cycle_count<=cycle_count+3'b1;
                                end
                            else
                                begin
                                    if (u_sec!=10'd999) 
                                        begin
                                            u_sec<=u_sec+10'b1;
                                        end
                                    else
                                        begin
                                            if (m_sec!=10'd999) 
                                                begin
                                                    m_sec<=m_sec+10'b1;
                                                end
                                            else
                                                begin
                                                    if (sec!=6'd59) 
                                                        begin
                                                            sec<=sec+6'b1;
                                                        end
                                                    else
                                                        begin
                                                            if (timer!=3'd5) 
                                                                begin
                                                                    timer<=timer+3'b1;
                                                                end
                                                            else
                                                                begin
                                                                    timer<=3'b0;
                                                                end
                                                            sec<=6'b0;
                                                        end
                                                    m_sec<=10'b0;
                                                end
                                            u_sec<=10'b0;
                                        end
                                end
                        end
                    2'b11: 
                        begin
                            if (cycle_count!=3'd7)
                                begin
                                    cycle_count<=cycle_count+3'b1;
                                end
                            else
                                begin
                                    if (u_sec!=10'd999) 
                                        begin
                                            u_sec<=u_sec+10'b1;
                                        end
                                    else
                                        begin
                                            if (m_sec!=10'd999) 
                                                begin
                                                    m_sec<=m_sec+10'b1;
                                                end
                                            else
                                                begin
                                                    if (sec!=6'd59) 
                                                        begin
                                                            sec<=sec+6'b1;
                                                        end
                                                    else
                                                        begin
                                                            if (timer!=3'd5) 
                                                                begin
                                                                    timer<=timer+3'b1;
                                                                end
                                                            else
                                                                begin
                                                                    timer<=3'b0;
                                                                end
                                                            sec<=6'b0;
                                                        end
                                                    m_sec<=10'b0;
                                                end
                                            u_sec<=10'b0;
                                        end
                                end
                        end
                endcase                
            end
    end

/////////double wash countr/////////
always @(posedge clk or negedge rst) 
    begin
        if (!rst) 
            begin
                firstwash<=1'b1;
            end
        else
            begin
                if (firstdone) 
                    begin
                        firstwash<=1'b0;    
                    end                
            end
    end



always @(posedge clk or negedge rst) 
    begin
        if (!rst) 
            begin
                wash_done<=1'b1;
            end
        else
            begin
                wash_done<=wash_done_reg;                
            end
    end


always @(posedge clk or negedge rst) 
    begin
        if (!rst) 
            begin
                state<=idle;
            end
        else
            begin
                state<=next_state;                
            end
    end

always @(*) 
    begin
        case (state)
            idle:
                begin
                    wash_done_reg=1'b1;
                    startover=1'b1;
                    firstdone=1'b0;
                    if (coin_in) 
                        begin
                            next_state=filling_water;
                            wash_done_reg=1'b0;
                        end
                    else
                        begin
                            next_state=idle;
                        end
                end
            filling_water:
                begin
                    startover=1'b0;
                    if (timer==3'd2) 
                        begin
                            next_state=washing;
                            startover=1'b1;    
                        end
                    else
                        begin
                            next_state=filling_water;
                        end
                end
            washing:
                begin
                    startover=1'b0;
                    if (timer==3'd5) 
                        begin
                            next_state=rinsing;
                            startover=1'b1;    
                        end
                    else
                        begin
                            next_state=washing;
                        end
                end
            rinsing:
                begin
                    startover=1'b0;
                    if (timer==3'd2) 
                        begin
                            if (double_wash==1'b1 && firstwash==1'b1) 
                                begin
                                    next_state=washing;
                                    firstdone=1'b1;
                                    startover=1'b1; 
                                end
                            else
                                begin
                                    next_state=spining;
                                    startover=1'b1;
                                end 
                        end
                    else
                        begin
                            next_state=rinsing;
                        end
                end
            spining:
                begin
                    startover=1'b0;
                    if (timer==3'd1) 
                        begin
                            if (timer_pause==1'b1) 
                                begin
                                    timer_wait=1'b1;   
                                end
                            else
                                begin
                                    timer_wait=1'b0;
                                end
                            next_state=idle;
                        end
                    else
                        begin
                            next_state=spining;
                        end
                end
        endcase
    end

endmodule