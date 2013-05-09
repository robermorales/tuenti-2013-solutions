% ---------------------------------------------
% PARAMETERS
% ---------------------------------------------
int: soldier_cost;
int: crematorium_cost;
int: gold_available;
int: w;
int: h;

% INFINITY is a param since can be used externally to outputs a flag (-1)
int: INFINITY;

% ---------------------------------------------
% GENERAL CONSTRAINTS
% ---------------------------------------------

% we cant train more soldiers than gold available for them
int: max_soldiers     = gold_available div soldier_cost;
var 0..max_soldiers: soldier_num;

% we cant explode more crematoriums than gold available for them
int: max_crematoriums = gold_available div crematorium_cost;
var 0..max_crematoriums: crematorium_num;

% we cant expend more than INFINITY seconds
var h..INFINITY: seconds;

% total cost should not be greather than gold available
constraint gold_available >= soldier_num * soldier_cost + crematorium_num * crematorium_cost;

% the input ratio is the maximum inputs Zs minus the ones that soldiers kills
var int: input_ratio = w - soldier_num;

% total size
int: real_size = w * (h-1);

% ---------------------------------------------
% OPTIMIZATION CONSTRAINTS
% ---------------------------------------------

% In case we have input of Zs, we survive the "seconds_for_a_invasion" at least one, plus one for each crematorium
% The seconds we can resist one invasion are proportional to the total size (w* (h-1)) divided by the input ratio
% We take into account that with only one Z we explode, since that: we operates on h-1 (h-1 rows full of Zs) and then
%  sum another second (the one Z in the last row)
constraint soldier_num <  w -> seconds <= ( ( real_size div ( w - soldier_num ) ) + 1 ) * ( crematorium_num + 1 );
% constraint soldier_num <  w -> seconds < INFINITY;

constraint soldier_num >= w -> seconds = INFINITY;

% ---------------------------------------------
% GLOBAL OPTIMIZATION
% ---------------------------------------------

solve maximize seconds;

% ---------------------------------------------
% DISPLAY RESULTS
% ---------------------------------------------

output [

show(seconds),

"\n gold_available   => ", show(gold_available),
"\n soldier_cost     => ", show(soldier_cost),
"\n crematorium_cost => ", show(crematorium_cost),
"\n h                => ", show(h),
"\n w                => ", show(w),
"\n seconds         => ", show(seconds),
"\n soldier_num     => ", show(soldier_num),
"\n crematorium_num => ", show(crematorium_num),

];


