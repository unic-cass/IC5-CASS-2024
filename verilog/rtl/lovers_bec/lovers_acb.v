// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

module acb (    
    input clk, 
    input rst,
    input enable,
    input configuration,
    input [162:0] A,
    input [162:0] B,

    output wire [162:0] C,

    output wire done);

    wire [162:0] z_tmp, c_tmp;
    assign C = (~configuration) ? c_tmp : z_tmp; 

    classic_squarer u1 (
        .a(z_tmp),
        .c(c_tmp)
    );

    interleaved_mult u2 (
        .A(A),
        .B(B),
        .clk(clk),
        .rst(rst),
        .start(enable),
        .Z(z_tmp),
        .done(done)
    );

endmodule
`default_nettype wire
