### eslint-disable ###
###expected
initial->s1_1->s1_3->s1_2->s1_4->s1_6->s1_5->s1_7->s1_5;
s1_3->s1_9;
s1_6->s1_8->s1_2;
s1_7->s1_8->s1_9->final;
###
for a in []
  for b in []
    foo
###DOT
digraph {
node[shape=box,style="rounded,filled",fillcolor=white];
initial[label="",shape=circle,style=filled,fillcolor=black,width=0.25,height=0.25];
final[label="",shape=doublecircle,style=filled,fillcolor=black,width=0.25,height=0.25];
s1_1[label="Program\nFor"];
s1_3[label="ArrayExpression\nArrayExpression:exit"];
s1_2[label="Identifier (a)\nIdentifier:exit (a)"];
s1_4[label="BlockStatement\nFor"];
s1_6[label="ArrayExpression\nArrayExpression:exit"];
s1_5[label="Identifier (b)\nIdentifier:exit (b)"];
s1_7[label="BlockStatement\nExpressionStatement\nIdentifier (foo)\nIdentifier:exit (foo)\nExpressionStatement:exit\nBlockStatement:exit"];
s1_9[label="For:exit\nProgram:exit"];
s1_8[label="For:exit\nBlockStatement:exit"];
initial->s1_1->s1_3->s1_2->s1_4->s1_6->s1_5->s1_7->s1_5;
s1_3->s1_9;
s1_6->s1_8->s1_2;
s1_7->s1_8->s1_9->final;
}
###
