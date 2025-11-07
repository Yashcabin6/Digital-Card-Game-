module memory_game (
    input wire clk,          // Clock input
    input fullrst,
    input wire rst,          // Reset input
    input wire flip_card, 
    input wire [15:0] cardss,
    input wire [2:0] card_id,
    output wire [7:0] leds  
);

reg [7:0] cards;            // State of each card (1 for face up, 0 for face down)
integer card1, card2;       // IDs of the two cards being flipped
reg [1:0] match_id;         // IDs of the two matched cards
reg match_found;            // Flag indicating if a match has been found 
integer n;                  // Integer to store decimal form of card_id

// Initialize variables
initial begin
    cards = 8'b00000000;    
    card1 = -1;         // Invalid card ID
    card2 = -1;         // Invalid card ID
    match_id = 2'b00;   // No match initially
    match_found = 0;        
end

// Convert card_id to decimal form
always @* begin
    n = card_id;
end

always @(posedge clk) begin
    if (fullrst) begin
        cards <= 8'b00000000; // Reset cards to face down
        card1 <= -1;    // Reset card IDs
        card2 <= -1;
        match_id <= 2'b00;    // Reset match ID
        match_found <= 0;     // Reset match found flag
    end else if (rst) begin
        cards <= 8'b00000000; // Reset cards to face down
        card1 <= -1;      // Reset card IDs
        card2 <= -1;
    end else if (flip_card && !match_found) begin
        if (cards[card_id] == 1'b0) begin // Flip the card if it's face down
            if (card1 == -1) begin    // First card flip
                card1 <= n;
            end else begin                 // Second card flip
                card2 = n;
                if (cardss[2*card1]==cardss[2*card2] && cardss[2*card1+1]==cardss[2*card2+1]) begin
                    // Cards match
                    match_id <= {cardss[card1+1],cardss[card1]};
                    match_found <= 1; // Set match found flag
                end
            end
            cards[card_id] <= 1'b1; // Update card state to face up
        end
    end
end

// Assign LEDs to represent the state of each card
assign leds = cards;

endmodule

module memory_game_tb;

    reg clk;
    reg fullrst;
    reg rst;
    reg flip_card;
    reg [15:0] cardss;
    reg [2:0] card_id;
    wire [7:0] leds;

    // Instantiate the memory_game module
    memory_game dut (
        .clk(clk),
        .fullrst(fullrst),
        .rst(rst),
        .flip_card(flip_card),
        .cardss(cardss),
        .card_id(card_id),
        .leds(leds)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Testbench
    initial begin
        clk = 0;
        fullrst = 0;
        rst = 0;
        flip_card = 0;
        cardss = 16'b1001011111110000;

        // Apply reset
        fullrst = 1;
        #10 fullrst = 0;

        // Example flips (you can add more as needed)
        #10 flip_card = 1; card_id = 3'b001;
        #10 flip_card = 0; card_id = 3'b111;
        #10 flip_card = 1;
        #10 begin
            flip_card = 0;
            $display("LEDs: %b Card ID: %b", leds, card_id);
            rst = 1;
            #10 rst = 0;
        end
        // End simulation
        $finish;
    end

endmodule
