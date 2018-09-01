###expected
initial->s2_1->final;
###
###expected
initial->s1_1->s1_2->s1_3;
s1_1->s1_3->final;
###
foo = a ? ->
###DOT
digraph {
node[shape=box,style="rounded,filled",fillcolor=white];
initial[label="",shape=circle,style=filled,fillcolor=black,width=0.25,height=0.25];
final[label="",shape=doublecircle,style=filled,fillcolor=black,width=0.25,height=0.25];
s2_1[label="FunctionExpression\nBlockStatement\nBlockStatement:exit\nFunctionExpression:exit"];
initial->s2_1->final;
}
digraph {
node[shape=box,style="rounded,filled",fillcolor=white];
initial[label="",shape=circle,style=filled,fillcolor=black,width=0.25,height=0.25];
final[label="",shape=doublecircle,style=filled,fillcolor=black,width=0.25,height=0.25];
s1_1[label="Program\nExpressionStatement\nAssignmentExpression\nIdentifier (foo)\nLogicalExpression\nIdentifier (a)\nIdentifier:exit (foo)\nIdentifier:exit (a)"];
s1_2[label="FunctionExpression\nFunctionExpression:exit"];
s1_3[label="LogicalExpression:exit\nAssignmentExpression:exit\nExpressionStatement:exit\nProgram:exit"];
initial->s1_1->s1_2->s1_3;
s1_1->s1_3->final;
}
###
