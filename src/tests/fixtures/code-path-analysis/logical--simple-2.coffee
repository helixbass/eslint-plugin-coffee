### eslint-disable ###
###expected
initial->s1_1->s1_2->s1_3->s1_4->s1_5;
s1_1->s1_5;
s1_2->s1_5;
s1_3->s1_5->final;
###
a or b or (c or d)
###DOT
digraph {
node[shape=box,style="rounded,filled",fillcolor=white];
initial[label="",shape=circle,style=filled,fillcolor=black,width=0.25,height=0.25];
final[label="",shape=doublecircle,style=filled,fillcolor=black,width=0.25,height=0.25];
s1_1[label="Program\nExpressionStatement\nLogicalExpression\nLogicalExpression\nIdentifier (a)\nIdentifier:exit (a)"];
s1_2[label="Identifier (b)\nIdentifier:exit (b)\nLogicalExpression:exit"];
s1_3[label="LogicalExpression\nIdentifier (c)\nIdentifier:exit (c)"];
s1_4[label="Identifier (d)\nIdentifier:exit (d)\nLogicalExpression:exit"];
s1_5[label="LogicalExpression:exit\nExpressionStatement:exit\nProgram:exit"];
initial->s1_1->s1_2->s1_3->s1_4->s1_5;
s1_1->s1_5;
s1_2->s1_5;
s1_3->s1_5->final;
}
###
