### eslint-disable ###
###expected
initial->s1_1->s1_3->s1_2->s1_5->s1_2;
s1_3->s1_6->s1_7->s1_8;
s1_5->s1_6;
s1_3->s1_7;
s1_6->s1_8->final;
###
try
  for x in xs
    ;
catch err
###DOT
digraph {
node[shape=box,style="rounded,filled",fillcolor=white];
initial[label="",shape=circle,style=filled,fillcolor=black,width=0.25,height=0.25];
final[label="",shape=doublecircle,style=filled,fillcolor=black,width=0.25,height=0.25];
s1_1[label="Program\nTryStatement\nBlockStatement\nFor"];
s1_3[label="Identifier (xs)\nIdentifier:exit (xs)"];
s1_2[label="Identifier (x)\nIdentifier:exit (x)"];
s1_5[label="BlockStatement\nBlockStatement:exit"];
s1_6[label="For:exit\nBlockStatement:exit"];
s1_7[label="CatchClause\nIdentifier (err)\nBlockStatement\nIdentifier:exit (err)\nBlockStatement:exit\nCatchClause:exit"];
s1_8[label="TryStatement:exit\nProgram:exit"];
initial->s1_1->s1_3->s1_2->s1_5->s1_2;
s1_3->s1_6->s1_7->s1_8;
s1_5->s1_6;
s1_3->s1_7;
s1_6->s1_8->final;
}
###
