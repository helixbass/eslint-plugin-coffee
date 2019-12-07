### eslint-disable ###
###expected
initial->s1_1->s1_3->s1_2->s1_4->s1_2;
s1_3->s1_5;
s1_4->s1_5->final;
###
for x, index in list
  foo()

###DOT
digraph {
node[shape=box,style="rounded,filled",fillcolor=white];
initial[label="",shape=circle,style=filled,fillcolor=black,width=0.25,height=0.25];
final[label="",shape=doublecircle,style=filled,fillcolor=black,width=0.25,height=0.25];
s1_1[label="Program\nFor"];
s1_3[label="Identifier (list)\nIdentifier:exit (list)"];
s1_2[label="Identifier (index)\nIdentifier (x)\nIdentifier:exit (index)\nIdentifier:exit (x)"];
s1_4[label="BlockStatement\nExpressionStatement\nCallExpression\nIdentifier (foo)\nIdentifier:exit (foo)\nCallExpression:exit\nExpressionStatement:exit\nBlockStatement:exit"];
s1_5[label="For:exit\nProgram:exit"];
initial->s1_1->s1_3->s1_2->s1_4->s1_2;
s1_3->s1_5;
s1_4->s1_5->final;
}
###
